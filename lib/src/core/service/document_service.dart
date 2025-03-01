import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/course_model.dart';
import '../model/document_model.dart';
import '../model/student_model.dart';
import '../model/transcript_model.dart';

class DocumentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseFirestore get firestore => _firestore;

  // Constants for document prefix format - use this throughout the class
  static const String USER_PREFIX = 'student_';

  /// Create or verify a user exists in Firestore (using univault structure).
  Future<void> createOrVerifyUser(String userName, String matricNumber) async {
    try {
      if (userName.isEmpty || matricNumber.isEmpty) {
        throw Exception("User name and matric number cannot be empty.");
      }

      // Use consistent document ID format
      final userDoc =
          _firestore.collection('univault').doc('$USER_PREFIX$matricNumber');

      final snapshot = await userDoc.get();
      if (!snapshot.exists) {
        await userDoc.set({
          'userName': userName,
          'matricNumber': matricNumber,
          'totalDocuments': FieldValue.increment(1),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await userDoc.update({
          'totalDocuments': FieldValue.increment(1),
        });
      }
    } catch (e) {
      throw Exception("Failed to create or verify user: $e");
    }
  }

  Future<List<Map<String, String>>> fetchAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('univault').get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            final docId = doc.id;

            // Check if it follows the student_XXXX format
            if (docId.startsWith(USER_PREFIX)) {
              final matricNumber = docId.substring(USER_PREFIX.length);
              return {
                'name': data['userName']?.toString() ?? 'Unknown',
                'matricNumber': matricNumber,
              };
            } else {
              return null; // Not a user document
            }
          })
          .where((item) => item != null) // Filter out non-user documents
          .cast<Map<String, String>>()
          .toList();
    } catch (e) {
      throw Exception("Error fetching users: $e");
    }
  }

  Future<List<String>> fetchLevelsForUser(String matricNumber) async {
    try {
      final userDoc =
          _firestore.collection('univault').doc('$USER_PREFIX$matricNumber');
      final snapshot = await userDoc.get();

      if (!snapshot.exists) {
        return [];
      }

      final levelsSnapshot = await userDoc.collection('levels').get();
      // Return the level document IDs (e.g., "300 Level", "200 Level")
      return levelsSnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception("Error fetching levels for user: $e");
    }
  }

  Future<List<DocumentModel>> fetchDocumentsByUser(String matricNumber) async {
    try {
      final userDoc =
          _firestore.collection('univault').doc('$USER_PREFIX$matricNumber');
      final userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        return [];
      }

      final levelsSnapshot = await userDoc.collection('levels').get();

      List<DocumentModel> allDocuments = [];
      for (var levelDoc in levelsSnapshot.docs) {
        final docsSnapshot =
            await levelDoc.reference.collection('documents').get();

        allDocuments.addAll(docsSnapshot.docs.map((doc) {
          return DocumentModel.fromMap(doc.id, doc.data());
        }));
      }

      return allDocuments;
    } catch (e) {
      throw Exception("Error fetching user documents: $e");
    }
  }

  Future<int> fetchTotalDocumentsCount() async {
    try {
      // Use a collection group query to count all documents in subcollections named "documents"
      final querySnapshot = await firestore.collectionGroup('documents').get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception("Error fetching total documents count: $e");
    }
  }

  Future<List<DocumentModel>> fetchRecentDocuments({
    int limit = 10,
    String? startAfterDocId,
  }) async {
    try {
      // Create the base query
      Query query = _firestore
          .collectionGroup('documents')
          .orderBy('timestamp', descending: true);

      // Apply pagination if a starting document is provided
      if (startAfterDocId != null) {
        // First get the document to start after
        final docSnapshots = await _firestore
            .collectionGroup('documents')
            .where(FieldPath.documentId, isEqualTo: startAfterDocId)
            .get();

        if (docSnapshots.docs.isNotEmpty) {
          query = query.startAfterDocument(docSnapshots.docs.first);
        }
      }

      // Apply the limit and execute the query
      final querySnapshot = await query.limit(limit).get();

      return querySnapshot.docs
          .map((doc) =>
              DocumentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If there's an indexing error, fall back to a client-side solution
      if (e.toString().contains('failed-precondition') ||
          e.toString().contains('requires an index')) {
        // Fallback approach without ordering on the server
        final querySnapshot = await _firestore
            .collectionGroup('documents')
            .limit(
                limit * 3) // Get more documents since we can't order on server
            .get();

        final docs = querySnapshot.docs
            .map((doc) => DocumentModel.fromMap(doc.id, doc.data()))
            .toList();

        // Sort them in memory
        docs.sort((a, b) {
          final aTime = a.timestamp ?? DateTime.now();
          final bTime = b.timestamp ?? DateTime.now();
          return bTime.compareTo(aTime); // Descending order
        });

        // Handle pagination in memory
        if (startAfterDocId != null) {
          final startIndex =
              docs.indexWhere((doc) => doc.id == startAfterDocId);
          if (startIndex != -1 && startIndex < docs.length - 1) {
            return docs.sublist(
                startIndex + 1,
                (startIndex + 1 + limit) > docs.length
                    ? docs.length
                    : (startIndex + 1 + limit));
          }
        }

        // If no startAfter or not found, return the first 'limit' documents
        return docs.take(limit).toList();
      } else {
        // For other errors, rethrow
        throw Exception('Error fetching recent documents: $e');
      }
    }
  }

  // Helper method to suggest index creation
  String getIndexCreationUrl() {
    return 'https://console.firebase.google.com/v1/r/project/academic-archival-system/firestore/indexes?create_exemption=CmRwcm9qZWN0cy9hY2FkZW1pYy1hcmNoaXZhbC1zeXN0ZW0vZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2RvY3VtZW50cy9maWVsZHMvdGltZXN0YW1wEAIaCAoEdGltZQ';
  }

  /// Parse transcript text into structured data
  Map<String, dynamic> _parseTranscript(String text) {
    final lines = text.split('\n');
    final student = _parseStudent(lines);
    final courses = _parseCourses(lines);
    final transcript = Transcript.fromStudent(Student(
      name: student.name,
      matricNumber: student.matricNumber,
      courseOfStudy: student.courseOfStudy,
      faculty: student.faculty,
      sex: student.sex,
      nationality: student.nationality,
      yearOfAdmission: student.yearOfAdmission,
      modeOfEntry: student.modeOfEntry,
      dateOfBirth: student.dateOfBirth,
      courses: courses,
    ));

    return {
      'student': {
        'name': student.name,
        'matricNumber': student.matricNumber,
        'courseOfStudy': student.courseOfStudy,
        'faculty': student.faculty,
        'sex': student.sex,
        'nationality': student.nationality,
        'yearOfAdmission': student.yearOfAdmission,
        'modeOfEntry': student.modeOfEntry,
        'dateOfBirth': student.dateOfBirth,
      },
      'courses': courses.map((course) => course.toMap()).toList(),
      'transcript': {
        'cumulativeUnitsRegistered': transcript.cumulativeUnitsRegistered,
        'cumulativeUnitsPassed': transcript.cumulativeUnitsPassed,
        'totalWeightedGradePoints': transcript.totalWeightedGradePoints,
        'cumulativeGpa': transcript.cumulativeGpa,
      },
    };
  }

  /// Parse letter text into structured data (simple example)
  Map<String, dynamic> _parseLetter(String text) {
    final lines = text.split('\n');
    final structured = <String, String>{};
    for (var line in lines) {
      final parts = line.split(': ');
      if (parts.length == 2) {
        structured[parts[0].toLowerCase()] = parts[1];
      }
    }
    structured['body'] = text;
    return structured;
  }

  Student _parseStudent(List<String> lines) {
    String name = '';
    String matricNumber = '';
    String courseOfStudy = '';
    String faculty = '';
    String sex = '';
    String nationality = '';
    int yearOfAdmission = 0;
    String modeOfEntry = '';
    String dateOfBirth = '';

    for (var line in lines) {
      if (line.contains('Name:')) name = line.replaceAll('Name:', '').trim();
      if (line.contains('Matric. No:')) {
        matricNumber = line.replaceAll('Matric. No:', '').trim();
      }
      if (line.contains('Course of Study:')) {
        courseOfStudy = line.replaceAll('Course of Study:', '').trim();
      }
      if (line.contains('Faculty:')) {
        faculty = line.replaceAll('Faculty:', '').trim();
      }
      if (line.contains('Sex:')) sex = line.replaceAll('Sex:', '').trim();
      if (line.contains('Nationality:')) {
        nationality = line.replaceAll('Nationality:', '').trim();
      }
      if (line.contains('Year of Admission:')) {
        yearOfAdmission =
            int.tryParse(line.replaceAll('Year of Admission:', '').trim()) ?? 0;
      }
      if (line.contains('Mode of Entry:')) {
        modeOfEntry = line.replaceAll('Mode of Entry:', '').trim();
      }
      if (line.contains('Date of Birth:')) {
        dateOfBirth = line.replaceAll('Date of Birth:', '').trim();
      }
    }

    return Student(
      name: name,
      matricNumber: matricNumber,
      courseOfStudy: courseOfStudy,
      faculty: faculty,
      sex: sex,
      nationality: nationality,
      yearOfAdmission: yearOfAdmission,
      modeOfEntry: modeOfEntry,
      dateOfBirth: dateOfBirth,
      courses: const [],
    );
  }

  List<Course> _parseCourses(List<String> lines) {
    List<Course> courses = [];
    bool inTable = false;

    for (var line in lines) {
      if (line.contains('COURSES TAKEN AND MARKS OBTAINED')) {
        inTable = true;
        continue;
      }
      if (inTable && line.contains('|')) {
        final parts = line
            .split('|')
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toList();
        if (parts.length >= 9) {
          // Ensure we have all columns
          final courseCode = parts[1];
          final session = parts[2];
          final description = parts[3];
          final units = int.tryParse(parts[4]) ?? 0;
          final status = parts[5];
          final marksPercentage = int.tryParse(parts[6]) ?? 0;
          final gradePoint = int.tryParse(parts[7]) ?? 0;
          final weightedGradePoint = int.tryParse(parts[8]) ?? 0;
          final remarks = parts[9];

          courses.add(Course(
            courseCode: courseCode,
            session: session,
            description: description,
            units: units,
            status: status,
            marksPercentage: marksPercentage,
            gradePoint: gradePoint,
            weightedGradePoint: weightedGradePoint,
            remarks: remarks,
            academicLevel: _inferAcademicLevel(courseCode),
          ));
        }
      }
    }

    return courses;
  }

  String _inferAcademicLevel(String courseCode) {
    // Use RegExp to find the first digit in the course code
    final digitMatch = RegExp(r'\d').stringMatch(courseCode);
    final level = digitMatch ?? '1'; // Default to '1' if no digit found
    return '${int.parse(level)}00 Level';
  }

  /// Save document metadata (with extracted text and structured data) to Firestore.
  Future<bool> saveDocument(DocumentModel document) async {
    try {
      if (document.matricNumber.isEmpty || document.level.isEmpty) {
        throw Exception("Document must have a matric number and level.");
      }

      final userDoc = _firestore
          .collection('univault')
          .doc('$USER_PREFIX${document.matricNumber}');

      // Check if user document exists and create if needed
      final userSnapshot = await userDoc.get();
      bool isNewUser = !userSnapshot.exists;
      if (isNewUser) {
        await userDoc.set({
          'userName': document.userName,
          'matricNumber': document.matricNumber,
          'totalDocuments': 1,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await userDoc.update({
          'totalDocuments': FieldValue.increment(1),
        });
      }

      // Ensure the level document exists
      final levelDocRef = userDoc.collection('levels').doc(document.level);
      final levelSnapshot = await levelDocRef.get();
      if (!levelSnapshot.exists) {
        await levelDocRef.set({
          'level': document.level,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Create a new document reference
      final docRef = levelDocRef.collection('documents').doc();

      Map<String, dynamic> structuredData = {};
      if (document.documentType == 'Transcript') {
        structuredData = _parseTranscript(document.text);
      } else if (document.documentType == 'Letter') {
        structuredData = _parseLetter(document.text);
      }

      final newDocument = DocumentModel(
        id: docRef.id,
        userName: document.userName,
        matricNumber: document.matricNumber,
        level: document.level,
        text: document.text,
        documentType: document.documentType,
        fileUrl: document.fileUrl,
        timestamp: document.timestamp ?? DateTime.now(),
        structuredData: structuredData.isNotEmpty ? structuredData : null,
      );

      await docRef.set(newDocument.toMap());
      // Update the total documents count
      await userDoc.update({
        'totalDocuments': FieldValue.increment(1),
      });
      return isNewUser;
    } catch (e) {
      throw Exception("Error saving document: $e");
    }
  }

  /// Update an existing document
  Future<void> updateDocument(DocumentModel document) async {
    try {
      if (document.id.isEmpty ||
          document.matricNumber.isEmpty ||
          document.level.isEmpty) {
        throw Exception("Document must have an id, matric number, and level.");
      }

      final docRef = _firestore
          .collection('univault')
          .doc('$USER_PREFIX${document.matricNumber}')
          .collection('levels')
          .doc(document.level)
          .collection('documents')
          .doc(document.id);

      // Check if document exists
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception("Document not found.");
      }

      // Update the document data
      Map<String, dynamic> updatedData = document.toMap();

      // If the document type is structured, update the structured data
      if (document.documentType == 'Transcript' ||
          document.documentType == 'Letter') {
        Map<String, dynamic> structuredData = {};
        if (document.documentType == 'Transcript') {
          structuredData = _parseTranscript(document.text);
        } else if (document.documentType == 'Letter') {
          structuredData = _parseLetter(document.text);
        }

        if (structuredData.isNotEmpty) {
          updatedData['structuredData'] = structuredData;
        }
      }

      await docRef.update(updatedData);
    } catch (e) {
      throw Exception("Error updating document: $e");
    }
  }

  /// Delete a document
  Future<void> deleteDocument(
      String documentId, String matricNumber, String level) async {
    try {
      if (documentId.isEmpty || matricNumber.isEmpty || level.isEmpty) {
        throw Exception(
            "Document ID, matric number, and level must be provided.");
      }

      final userDoc =
          _firestore.collection('univault').doc('$USER_PREFIX$matricNumber');

      final docRef = userDoc
          .collection('levels')
          .doc(level)
          .collection('documents')
          .doc(documentId);

      // Check if document exists
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception("Document not found.");
      }

      // Delete the document
      await docRef.delete();

      // Update the total documents count
      await userDoc.update({
        'totalDocuments': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception("Error deleting document: $e");
    }
  }

  /// Fetch a single document by ID
  Future<DocumentModel?> fetchDocumentById(
      String documentId, String matricNumber, String level) async {
    try {
      if (documentId.isEmpty || matricNumber.isEmpty || level.isEmpty) {
        throw Exception(
            "Document ID, matric number, and level must be provided.");
      }

      final docRef = _firestore
          .collection('univault')
          .doc('$USER_PREFIX$matricNumber')
          .collection('levels')
          .doc(level)
          .collection('documents')
          .doc(documentId);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        return null;
      }

      return DocumentModel.fromMap(docSnapshot.id, docSnapshot.data()!);
    } catch (e) {
      throw Exception("Error fetching document by ID: $e");
    }
  }

  /// Search documents based on various criteria
  Future<List<DocumentModel>> searchDocuments({
    String? query,
    String? level,
    String? documentType,
    String? dateRange,
    int limit = 20,
    String? startAfterDocId,
  }) async {
    try {
      // Start with a base query on the documents collection group
      Query searchQuery = _firestore.collectionGroup('documents');

      // Apply filters based on provided criteria
      if (documentType != null && documentType.isNotEmpty) {
        searchQuery =
            searchQuery.where('documentType', isEqualTo: documentType);
      }

      if (level != null && level.isNotEmpty) {
        searchQuery = searchQuery.where('level', isEqualTo: level);
      }

      // Handle date range filtering
      if (dateRange != null && dateRange.isNotEmpty) {
        final dates = dateRange.split(' to ');
        if (dates.length == 2) {
          final startDate = DateTime.tryParse(dates[0])?.toUtc();
          final endDate = DateTime.tryParse(dates[1])?.toUtc();
          if (startDate != null) {
            searchQuery = searchQuery.where('timestamp',
                isGreaterThanOrEqualTo: startDate);
          }
          if (endDate != null) {
            final adjustedEndDate = endDate.add(const Duration(days: 1));
            searchQuery =
                searchQuery.where('timestamp', isLessThan: adjustedEndDate);
          }
        }
      }

      // Add ordering by timestamp (descending)
      searchQuery = searchQuery.orderBy('timestamp', descending: true);

      // Apply pagination if a starting document is provided
      if (startAfterDocId != null) {
        final docSnapshots = await _firestore
            .collectionGroup('documents')
            .where(FieldPath.documentId, isEqualTo: startAfterDocId)
            .get();

        if (docSnapshots.docs.isNotEmpty) {
          searchQuery = searchQuery.startAfterDocument(docSnapshots.docs.first);
        }
      }

      // Apply limit and execute query
      final querySnapshot = await searchQuery.limit(limit).get();
      List<DocumentModel> results = querySnapshot.docs
          .map((doc) =>
              DocumentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // If text search is requested, filter results in memory
      if (query != null && query.isNotEmpty) {
        final normalizedQuery = query.toLowerCase();
        results = results.where((doc) {
          final text = doc.text.toLowerCase();
          final userName = doc.userName.toLowerCase();
          final matricNumber = doc.matricNumber.toLowerCase();
          return text.contains(normalizedQuery) ||
              userName.contains(normalizedQuery) ||
              matricNumber.contains(normalizedQuery);
        }).toList();
      }

      return results;
    } catch (e) {
      throw Exception("Error searching documents: $e");
    }
  }

  /// Fetch student data from Firestore
  Future<Map<String, dynamic>> fetchStudent(String matricNumber) async {
    try {
      if (matricNumber.isEmpty) {
        throw Exception("Matric number must be provided.");
      }

      final userDoc =
          _firestore.collection('univault').doc('$USER_PREFIX$matricNumber');
      final snapshot = await userDoc.get();

      if (!snapshot.exists) {
        throw Exception("Student not found.");
      }

      return snapshot.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Error fetching student: $e");
    }
  }

  Future<List<DocumentModel>> fetchDocuments(String matricNumber,
      {String? level}) async {
    try {
      if (matricNumber.isEmpty) {
        throw Exception("Matric number must be provided.");
      }

      final userDoc =
          _firestore.collection('univault').doc('$USER_PREFIX$matricNumber');
      final userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        return [];
      }

      if (level != null) {
        final levelRef = userDoc.collection('levels').doc(level);
        final levelSnapshot = await levelRef.get();

        if (!levelSnapshot.exists) {
          return [];
        }

        final snapshot = await levelRef.collection('documents').get();

        return snapshot.docs
            .map((doc) => DocumentModel.fromMap(doc.id, doc.data()))
            .toList();
      } else {
        // Fetch all documents across all levels
        final levelsSnapshot = await userDoc.collection('levels').get();
        List<DocumentModel> allDocuments = [];

        for (var levelDoc in levelsSnapshot.docs) {
          final docsSnapshot =
              await levelDoc.reference.collection('documents').get();
          allDocuments.addAll(docsSnapshot.docs
              .map((doc) => DocumentModel.fromMap(doc.id, doc.data())));
        }

        return allDocuments;
      }
    } catch (e) {
      throw Exception("Error fetching documents: $e");
    }
  }
}
