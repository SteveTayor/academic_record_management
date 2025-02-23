import 'student_model.dart';

class Transcript {
  final Student student;
  final int cumulativeUnitsRegistered;
  final int cumulativeUnitsPassed;
  final int totalWeightedGradePoints;
  final double cumulativeGpa;

  const Transcript({
    required this.student,
    required this.cumulativeUnitsRegistered,
    required this.cumulativeUnitsPassed,
    required this.totalWeightedGradePoints,
    required this.cumulativeGpa,
  });

  factory Transcript.fromStudent(Student student) {
    final courses = student.courses;
    final cumulativeUnitsRegistered = courses.fold(0, (sum, course) => sum + course.units);
    final cumulativeUnitsPassed = courses
        .where((course) => course.remarks == 'Passed')
        .fold(0, (sum, course) => sum + course.units);
    final totalWeightedGradePoints = courses.fold(0, (sum, course) => sum + course.weightedGradePoint);
    final cumulativeGpa = cumulativeUnitsRegistered > 0
        ? totalWeightedGradePoints / cumulativeUnitsRegistered
        : 0.0;
    return Transcript(
      student: student,
      cumulativeUnitsRegistered: cumulativeUnitsRegistered,
      cumulativeUnitsPassed: cumulativeUnitsPassed,
      totalWeightedGradePoints: totalWeightedGradePoints,
      cumulativeGpa: cumulativeGpa,
    );
  }

  @override
  String toString() {
    return 'Transcript(student: ${student.name}, gpa: $cumulativeGpa)';
  }
}