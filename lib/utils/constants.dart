// Dart concept demonstration:
// - Top-level constants using const
// - Application string literals and configuration values

class AppConstants {
  static const String appName = 'Smart Student Companion';
  static const String appVersion = '1.0.0';
  static const String universityName = 'Charotar University of Science and Technology';
  static const String academicTerm = 'Academic Year 2026 - Term II';
  
  // Storage keys
  static const String keyStudentProfile = 'sp_student_profile';
  static const String keyNotesList = 'sp_notes_list';
  static const String keyRegisteredCourses = 'sp_registered_courses';
  static const String keyAssignments = 'sp_assignments';
  static const String keyAttendance = 'sp_attendance';
  static const String keyEvents = 'sp_events';
  static const String keyNotifications = 'sp_notifications';

  // Preferences keys (Practical 5)
  static const String keyThemeMode = 'sp_theme_mode'; // 'light' | 'dark'
  static const String keyPreferredSemester = 'sp_preferred_semester';
  static const String keyNotificationsEnabled = 'sp_notifications_enabled';
  static const String keyIsLoggedIn = 'sp_is_logged_in';

  // Attendance target standard
  static const double minimumAttendancePercent = 75.0;
}
