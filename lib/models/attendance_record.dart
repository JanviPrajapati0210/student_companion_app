// Dart concept demonstration:
// - Arithmetic calculations (percentage = attended / total * 100)
// - Conditional logic (isShortage warning flag < 75.0)
// - Computed getters, methods to update state dynamically

class AttendanceRecord {
  final String courseCode;
  final String courseName;
  int totalClasses;
  int attendedClasses;
  final int facultyTargetPercentage;

  AttendanceRecord({
    required this.courseCode,
    required this.courseName,
    required this.totalClasses,
    required this.attendedClasses,
    this.facultyTargetPercentage = 75,
  });

  // Missed classes computed via subtraction
  int get missedClasses => totalClasses - attendedClasses;

  // Percentage computed via arithmetic division and multiplication
  double get percentage {
    if (totalClasses == 0) return 100.0;
    return (attendedClasses / totalClasses) * 100.0;
  }

  // String formatting helper for display
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';

  // Boolean check for attendance shortage (< 75%)
  bool get isShortage => percentage < facultyTargetPercentage;

  // Number of consecutive classes needed to reach 75%
  int classesNeededForTarget(double target) {
    if (percentage >= target) return 0;
    // Formula: (attended + x) / (total + x) >= target/100
    // attended + x >= 0.75 * total + 0.75 * x
    // 0.25 * x >= 0.75 * total - attended
    // x >= (0.75 * total - attended) / 0.25
    double targetFraction = target / 100.0;
    double needed = (targetFraction * totalClasses - attendedClasses) / (1 - targetFraction);
    return needed > 0 ? needed.ceil() : 0;
  }

  // Record an attendance action (Present or Absent)
  void markClass({required bool wasPresent}) {
    totalClasses += 1;
    if (wasPresent) {
      attendedClasses += 1;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'courseCode': courseCode,
      'courseName': courseName,
      'totalClasses': totalClasses,
      'attendedClasses': attendedClasses,
      'facultyTargetPercentage': facultyTargetPercentage,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      courseCode: map['courseCode'] ?? '',
      courseName: map['courseName'] ?? '',
      totalClasses: map['totalClasses'] is int ? map['totalClasses'] : 0,
      attendedClasses: map['attendedClasses'] is int ? map['attendedClasses'] : 0,
      facultyTargetPercentage: map['facultyTargetPercentage'] is int ? map['facultyTargetPercentage'] : 75,
    );
  }
}
