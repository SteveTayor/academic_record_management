import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/course_model.dart';
import '../model/document_model.dart';
import '../model/student_model.dart';
import '../model/transcript_model.dart';

class DocumentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseFirestore get firestore => _firestore;

  /// Create or verify a user exists in Firestore (using univault structure).
  Future<void> createOrVerifyUser(String userName, String matricNumber) async {
    try {
      if (userName.isEmpty || matricNumber.isEmpty) {
        throw Exception("User name and matric number cannot be empty.");
      }
      final userDoc =
          _firestore.collection('univault').doc('student_$matricNumber');
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
            return {
              'name': data['userName']?.toString() ?? 'Unknown',
              'matricNumber': doc.id.replaceFirst('student_', ''),
            };
          })
          .toList()
          .cast<Map<String, String>>();
    } catch (e) {
      throw Exception("Error fetching users: $e");
    }
  }

  Future<List<DocumentModel>> fetchDocumentsByUser(String matricNumber) async {
    try {
      final userDoc =
          _firestore.collection('univault').doc('student_$matricNumber');
      final levelsSnapshot = await userDoc.collection('levels').get();

      List<DocumentModel> allDocuments = [];
      for (var levelDoc in levelsSnapshot.docs) {
        final docsSnapshot =
            await levelDoc.reference.collection('documents').get();
        allDocuments.addAll(docsSnapshot.docs
            .map((doc) => DocumentModel.fromMap(doc.id, doc.data())));
      }
      return allDocuments;
    } catch (e) {
      throw Exception("Error fetching user documents: $e");
    }
  }
  
  Future<List<DocumentModel>> fetchRecentDocuments({int limit = 3}) async {
    try {
      // First try with the collectionGroup query that requires an index
      try {
        final querySnapshot = await _firestore
            .collectionGroup('documents')
            .orderBy('timestamp', descending: true)
            .limit(limit)
            .get();
            
        return querySnapshot.docs
            .map((doc) => DocumentModel.fromMap(doc.id, doc.data()))
            .toList();
      } catch (e) {
        // If the index doesn't exist, use a fallback approach
        if (e.toString().contains('failed-precondition') || 
            e.toString().contains('requires an index')) {
          // Fallback: Get recent documents without ordering
          final querySnapshot = await _firestore
              .collectionGroup('documents')
              .limit(limit * 3) // Get more documents since we can't order them
              .get();
              
          final docs = querySnapshot.docs
              .map((doc) => DocumentModel.fromMap(doc.id, doc.data()))
              .toList();
              
          // Sort them in memory (not as efficient, but works without index)
          docs.sort((a, b) {
            final aTime = a.timestamp ?? DateTime.now();
            final bTime = b.timestamp ?? DateTime.now();
            return bTime.compareTo(aTime); // Descending order
          });
          
          // Return only the number requested
          return docs.take(limit).toList();
        } else {
          // For other errors, rethrow
          rethrow;
        }
      }
    } catch (e) {
      throw Exception('Error fetching recent documents: $e');
    }
  }
  
  // Helper method to suggest index creation
  String getIndexCreationUrl() {
    return 'https://console.firebase.google.com/v1/r/project/academic-archival-system/firestore/indexes?create_exemption=CmRwcm9qZWN0cy9hY2FkZW1pYy1hcmNoaXZhbC1zeXN0ZW0vZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2RvY3VtZW50cy9maWVsZHMvdGltZXN0YW1wEAIaCAoEdGltZQ';
  }

  // Future<List<Map<String, String>>> fetchAllUsers() async {
  //   try {
  //     final querySnapshot = await _firestore.collection('univault').get();
  //     return querySnapshot.docs
  //         .map((doc) {
  //           final data = doc.data();
  //           return {
  //             'name': data['userName']?.toString() ?? 'Unknown',
  //             'matricNumber': doc.id.replaceFirst('student_', ''),
  //           };
  //         })
  //         .toList()
  //         .cast<Map<String, String>>();
  //   } catch (e) {
  //     throw Exception("Error fetching users: $e");
  //   }
  // }

  // Future<List<DocumentModel>> fetchDocumentsByUser(String matricNumber) async {
  //   try {
  //     final userDoc =
  //         _firestore.collection('univault').doc('student_$matricNumber');
  //     final levelsSnapshot = await userDoc.collection('levels').get();

  //     List<DocumentModel> allDocuments = [];
  //     for (var levelDoc in levelsSnapshot.docs) {
  //       final docsSnapshot =
  //           await levelDoc.reference.collection('documents').get();
  //       allDocuments.addAll(docsSnapshot.docs
  //           .map((doc) => DocumentModel.fromMap(doc.id, doc.data())));
  //     }
  //     return allDocuments;
  //   } catch (e) {
  //     throw Exception("Error fetching user documents: $e");
  //   }
  // }

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
      if (line.contains('Matric. No:'))
        matricNumber = line.replaceAll('Matric. No:', '').trim();
      if (line.contains('Course of Study:'))
        courseOfStudy = line.replaceAll('Course of Study:', '').trim();
      if (line.contains('Faculty:'))
        faculty = line.replaceAll('Faculty:', '').trim();
      if (line.contains('Sex:')) sex = line.replaceAll('Sex:', '').trim();
      if (line.contains('Nationality:'))
        nationality = line.replaceAll('Nationality:', '').trim();
      if (line.contains('Year of Admission:'))
        yearOfAdmission =
            int.tryParse(line.replaceAll('Year of Admission:', '').trim()) ?? 0;
      if (line.contains('Mode of Entry:'))
        modeOfEntry = line.replaceAll('Mode of Entry:', '').trim();
      if (line.contains('Date of Birth:'))
        dateOfBirth = line.replaceAll('Date of Birth:', '').trim();
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
      courses: [],
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
    final level = digitMatch != null
        ? digitMatch
        : '1'; // Default to '1' if no digit found
    return '${int.parse(level)}00 Level';
  }

  /// Save document metadata (with extracted text and structured data) to Firestore.
  Future<void> saveDocument(DocumentModel document) async {
    try {
      if (document.matricNumber.isEmpty || document.level.isEmpty) {
        throw Exception("Document must have a matric number and level.");
      }
      final userDoc = _firestore
          .collection('univault')
          .doc('student_${document.matricNumber}');

      final docRef = userDoc
          .collection('levels')
          .doc(document.level)
          .collection('documents')
          .doc();

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
        fileUrl: '', // No file upload
        timestamp: document.timestamp,
        structuredData: structuredData.isNotEmpty ? structuredData : null,
      );

      await docRef.set(newDocument.toMap());
    } catch (e) {
      throw Exception("Error saving document: $e");
    }
  }

  /// Fetch student data from Firestore
  Future<Map<String, dynamic>> fetchStudent(String matricNumber) async {
    try {
      if (matricNumber.isEmpty) {
        throw Exception("Matric number must be provided.");
      }

      final userDoc =
          _firestore.collection('univault').doc('student_$matricNumber');
      final snapshot = await userDoc.get();

      if (!snapshot.exists) {
        throw Exception("Student not found.");
      }

      return snapshot.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Error fetching student: $e");
    }
  }

  /// Fetch All Documents for a User
  Future<List<DocumentModel>> fetchDocuments(String matricNumber,
      {String? level}) async {
    try {
      if (matricNumber.isEmpty) {
        throw Exception("Matric number must be provided.");
      }

      final userDoc =
          _firestore.collection('univault').doc('student_$matricNumber');

      QuerySnapshot<Map<String, dynamic>> snapshot;
      if (level != null) {
        snapshot = await userDoc
            .collection('levels')
            .doc(level)
            .collection('documents')
            .get();
      } else {
        snapshot = await userDoc.collection('documents').get();
      }

      return snapshot.docs
          .map((doc) => DocumentModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception("Error fetching documents: $e");
    }
  }
}
