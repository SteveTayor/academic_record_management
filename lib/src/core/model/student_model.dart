import 'package:flutter/foundation.dart';
import 'course_model.dart';

@immutable
class Student {
  final String name;
  final String matricNumber;
  final String courseOfStudy;
  final String faculty;
  final String sex;
  final String nationality;
  final int yearOfAdmission;
  final String modeOfEntry;
  final String dateOfBirth;
  final int? yearOfGraduation;
  final String? classOfDegree;
  final List<Course> courses;

  const Student({
    required this.name,
    required this.matricNumber,
    required this.courseOfStudy,
    required this.faculty,
    required this.sex,
    required this.nationality,
    required this.yearOfAdmission,
    required this.modeOfEntry,
    required this.dateOfBirth,
    this.yearOfGraduation,
    this.classOfDegree,
    this.courses = const [],
  });

  @override
  String toString() {
    return 'Student(name: $name, matricNumber: $matricNumber, courses: ${courses.length})';
  }
}