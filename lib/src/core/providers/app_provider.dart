import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/course_model.dart';
import '../model/document_model.dart';
import '../model/student_model.dart';
import '../model/transcript_model.dart';
import '../service/document_service.dart';

class AppState extends ChangeNotifier {
  DocumentModel? _currentDocument;
  Student? _currentStudent;
  Transcript? _currentTranscript;
  String? _extractedText;
  String _documentType = 'Other'; // Default document type
  final DocumentService _firebaseService = DocumentService();

  DocumentModel? get currentDocument => _currentDocument;
  Student? get currentStudent => _currentStudent;
  Transcript? get currentTranscript => _currentTranscript;
  String? get extractedText => _extractedText;
  String get documentType => _documentType;

  void setCurrentDocument(DocumentModel document) async {
    _currentDocument = document;
    _extractedText = document.text;
    _documentType = document.documentType;

    // Dynamically fetch or construct the Student object
    try {
      _currentStudent = await document.getStudent(_firebaseService);
      if (_documentType == 'Transcript') {
        _currentTranscript = _parseTranscript(_extractedText ?? '');
      } else {
        _currentTranscript = null;
      }
    } catch (e) {
      print('Error fetching student: $e');
      _currentStudent = null;
    }
    notifyListeners();
  }

  void setExtractedText(String text) {
    _extractedText = text;
    _currentDocument = _currentDocument?.copyWith(text: text);
    if (_documentType == 'Transcript') {
      _currentTranscript = _parseTranscript(text);
    }
    notifyListeners();
  }

  void setDocumentType(String type) {
    _documentType = type;
    _currentDocument = _currentDocument?.copyWith(documentType: type);
    if (type == 'Transcript') {
      _currentTranscript = _parseTranscript(_extractedText ?? '');
    } else {
      _currentTranscript = null;
    }
    notifyListeners();
  }

  void setStudent(Student student) {
    _currentStudent = student;
    _currentDocument = _currentDocument?.copyWith(
      userName: student.name,
      matricNumber: student.matricNumber,
    );
    if (_documentType == 'Transcript') {
      _currentTranscript = _parseTranscript(_extractedText ?? '');
    }
    notifyListeners();
  }

  // Helper method to parse transcript text into Student, Course, and Transcript
  Transcript? _parseTranscript(String text) {
    try {
      final lines = text.split('\n');
      Student student = _parseStudent(lines);
      List<Course> courses = _parseCourses(lines);
      student = Student(
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
      );
      return Transcript.fromStudent(student);
    } catch (e) {
      print('Error parsing transcript: $e');
      return null;
    }
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
    // Use RegExp or iterate to find the first digit in the course code
    final digitMatch = RegExp(r'\d').stringMatch(courseCode);
    final level = digitMatch ?? '1'; // Default to '1' if no digit found
    return '${int.parse(level)}00 Level';
  }
}
