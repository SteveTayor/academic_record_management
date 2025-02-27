import 'package:archival_system/src/core/service/document_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_model.dart';


class DocumentModel {
  final String id;
  final String userName;
  final String matricNumber;
  final String level;
  final String text; // Raw OCR text
  final String documentType; // e.g., "Transcript", "Letter"
  final String fileUrl; // Empty since no file upload
  final DateTime timestamp;
  final Map<String, dynamic>? structuredData; // For parsed transcript/letter data

  DocumentModel({
    required this.id,
    required this.userName,
    required this.matricNumber,
    required this.level,
    required this.text,
    required this.documentType,
    required this.fileUrl,
    required this.timestamp,
    this.structuredData, // Optional for parsed data
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'matricNumber': matricNumber,
      'level': level,
      'text': text,
      'documentType': documentType,
      'fileUrl': fileUrl,
      'timestamp': timestamp,
      'structuredData': structuredData ?? {},
    };
  }

  factory DocumentModel.fromMap(String id, Map<String, dynamic> map) {
    return DocumentModel(
      id: id,
      userName: map['userName'] as String,
      matricNumber: map['matricNumber'] as String,
      level: map['level'] as String,
      text: map['text'] as String,
      documentType: map['documentType'] as String,
      fileUrl: map['fileUrl'] as String? ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      structuredData: map['structuredData'] as Map<String, dynamic>?,
    );
  }
  // Add copyWith for immutable updates
  DocumentModel copyWith({
    String? id,
    String? userName,
    String? matricNumber,
    String? level,
    String? text,
    String? documentType,
    String? fileUrl,
    DateTime? timestamp,
    Map<String, dynamic>? structuredData,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      matricNumber: matricNumber ?? this.matricNumber,
      level: level ?? this.level,
      text: text ?? this.text,
      documentType: documentType ?? this.documentType,
      fileUrl: fileUrl ?? this.fileUrl,
      timestamp: timestamp ?? this.timestamp,
      structuredData: structuredData ?? this.structuredData,
    );
  }

  // Helper method to fetch or construct the associated Student (optional, for convenience)
  Future<Student> getStudent(DocumentService docService) async {
    final studentData = await docService.fetchStudent(matricNumber);
    return Student(
      name: studentData['userName'] as String,
      matricNumber: matricNumber,
      courseOfStudy: studentData['courseOfStudy'] ?? '',
      faculty: studentData['faculty'] ?? '',
      sex: studentData['sex'] ?? '',
      nationality: studentData['nationality'] ?? '',
      yearOfAdmission: studentData['yearOfAdmission'] as int? ?? 0,
      modeOfEntry: studentData['modeOfEntry'] ?? '',
      dateOfBirth: studentData['dateOfBirth'] ?? '',
      courses: [], // Populate courses separately if needed
    );
  }
}