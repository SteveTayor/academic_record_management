
class Course {
  final String courseCode;
  final String session;
  final String description;
  final int units;
  final String status;
  final int marksPercentage;
  final int gradePoint;
  final int weightedGradePoint;
  final String remarks;
  final String? academicLevel;

  const Course({
    required this.courseCode,
    required this.session,
    required this.description,
    required this.units,
    required this.status,
    required this.marksPercentage,
    required this.gradePoint,
    required this.weightedGradePoint,
    required this.remarks,
    this.academicLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'courseCode': courseCode,
      'session': session,
      'description': description,
      'units': units,
      'status': status,
      'marksPercentage': marksPercentage,
      'gradePoint': gradePoint,
      'weightedGradePoint': weightedGradePoint,
      'remarks': remarks,
      'academicLevel': academicLevel,
    };
  }

  @override
  String toString() {
    return 'Course(courseCode: $courseCode, session: $session, academicLevel: $academicLevel)';
  }
}