import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../models/attendance_record.dart';
import '../models/assignment.dart';
import '../models/note.dart';
import '../models/university_event.dart';
import '../models/app_notification.dart';
import '../utils/constants.dart';
import 'mock_data_service.dart';
import 'database_service.dart';

// Dart concept demonstration:
// - Singleton pattern with private constructor and static instance
// - Asynchronous programming: Future<T>, async, and await
// - Error handling: try, catch, and finally
// - JSON encoding and decoding (jsonEncode, jsonDecode)

class StorageService {
  // Private constructor for Singleton
  StorageService._internal();

  // Static single instance
  static final StorageService _instance = StorageService._internal();

  // Factory constructor returning the singleton instance
  factory StorageService() => _instance;

  SharedPreferences? _prefs;

  // Initialize SharedPreferences asynchronously
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // -------------------------------------------------------------
  // AUTHENTICATION & SESSION
  // -------------------------------------------------------------
  static const String keyIsLoggedIn = 'sp_is_logged_in';
  static const String keyUserPassword = 'sp_user_password';

  Future<bool> isLoggedIn() async {
    await init();
    return _prefs?.getBool(keyIsLoggedIn) ?? true; // Default true or false
  }

  Future<void> setLoggedIn(bool value) async {
    await init();
    await _prefs?.setBool(keyIsLoggedIn, value);
  }

  Future<bool> authenticateStudent(String email, String password) async {
    await init();
    final student = await getStudent();
    
    // Allow demo student login or registered email matching
    final isEmailMatch = student.email.toLowerCase() == email.trim().toLowerCase() ||
        email.trim().toLowerCase() == 'alex.morgan@charusat.edu.in' ||
        email.trim().toLowerCase() == '24aiml052';

    if (isEmailMatch && password.isNotEmpty) {
      await setLoggedIn(true);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await init();
    await setLoggedIn(false);
  }

  // -------------------------------------------------------------
  // PREFERENCES (Practical 5)
  // -------------------------------------------------------------
  Future<String> getThemeMode() async {
    await init();
    return _prefs?.getString(AppConstants.keyThemeMode) ?? 'light';
  }

  Future<void> setThemeMode(String mode) async {
    await init();
    await _prefs?.setString(AppConstants.keyThemeMode, mode);
  }

  Future<int> getPreferredSemester() async {
    await init();
    return _prefs?.getInt(AppConstants.keyPreferredSemester) ?? 4;
  }

  Future<void> setPreferredSemester(int semester) async {
    await init();
    await _prefs?.setInt(AppConstants.keyPreferredSemester, semester);
  }

  Future<bool> getNotificationsEnabled() async {
    await init();
    return _prefs?.getBool(AppConstants.keyNotificationsEnabled) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await init();
    await _prefs?.setBool(AppConstants.keyNotificationsEnabled, enabled);
  }

  // -------------------------------------------------------------
  // STUDENT PROFILE
  // -------------------------------------------------------------
  Future<Student> getStudent() async {
    await init();
    final jsonStr = _prefs?.getString(AppConstants.keyStudentProfile);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        return Student.fromMap(map);
      } catch (e) {
        // Fallback to initial if parse fails
        return MockDataService.getInitialStudent();
      }
    }
    final initial = MockDataService.getInitialStudent();
    await saveStudent(initial);
    return initial;
  }

  Future<void> saveStudent(Student student) async {
    await init();
    await _prefs?.setString(
      AppConstants.keyStudentProfile,
      jsonEncode(student.toMap()),
    );
  }

  // -------------------------------------------------------------
  // NOTES CRUD
  // -------------------------------------------------------------
  Future<List<Note>> getNotes() async {
    await init();
    final jsonStr = _prefs?.getString(AppConstants.keyNotesList);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((item) => Note.fromMap(item as Map<String, dynamic>)).toList();
      } catch (e) {
        return MockDataService.getInitialNotes();
      }
    }
    final initialNotes = MockDataService.getInitialNotes();
    await saveNotes(initialNotes);
    return initialNotes;
  }

  Future<void> saveNotes(List<Note> notes) async {
    await init();
    final list = notes.map((note) => note.toMap()).toList();
    await _prefs?.setString(AppConstants.keyNotesList, jsonEncode(list));
  }

  Future<void> addNote(Note note) async {
    final notes = await getNotes();
    notes.insert(0, note); // Add to beginning
    await saveNotes(notes);
  }

  Future<void> updateNote(Note updatedNote) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      notes[index] = updatedNote;
      await saveNotes(notes);
    }
  }

  Future<void> deleteNote(String noteId) async {
    final notes = await getNotes();
    notes.removeWhere((n) => n.id == noteId);
    await saveNotes(notes);
  }

  // -------------------------------------------------------------
  // COURSES & REGISTRATION
  // -------------------------------------------------------------
  Future<List<Course>> getCourses() async {
    await init();
    final jsonStr = _prefs?.getString(AppConstants.keyRegisteredCourses);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((c) => Course.fromMap(c as Map<String, dynamic>)).toList();
      } catch (e) {
        return MockDataService.getInitialCourses();
      }
    }
    final initial = MockDataService.getInitialCourses();
    await saveCourses(initial);
    return initial;
  }

  Future<void> saveCourses(List<Course> courses) async {
    await init();
    final list = courses.map((c) => c.toMap()).toList();
    await _prefs?.setString(AppConstants.keyRegisteredCourses, jsonEncode(list));
  }

  Future<bool> toggleCourseRegistration(String courseCode) async {
    final courses = await getCourses();
    final index = courses.indexWhere((c) => c.code == courseCode);
    if (index != -1) {
      courses[index].isRegistered = !courses[index].isRegistered;
      await saveCourses(courses);
      return courses[index].isRegistered;
    }
    return false;
  }

  // -------------------------------------------------------------
  // ATTENDANCE
  // -------------------------------------------------------------
  Future<List<AttendanceRecord>> getAttendance() async {
    await init();
    final jsonStr = _prefs?.getString(AppConstants.keyAttendance);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((item) => AttendanceRecord.fromMap(item as Map<String, dynamic>)).toList();
      } catch (e) {
        return MockDataService.getInitialAttendance();
      }
    }
    final initial = MockDataService.getInitialAttendance();
    await saveAttendance(initial);
    return initial;
  }

  Future<void> saveAttendance(List<AttendanceRecord> records) async {
    await init();
    final list = records.map((r) => r.toMap()).toList();
    await _prefs?.setString(AppConstants.keyAttendance, jsonEncode(list));
  }

  Future<void> markAttendance(String courseCode, bool wasPresent) async {
    final records = await getAttendance();
    final index = records.indexWhere((r) => r.courseCode == courseCode);
    if (index != -1) {
      records[index].markClass(wasPresent: wasPresent);
      await saveAttendance(records);
    }
  }

  // -------------------------------------------------------------
  // ASSIGNMENTS
  // -------------------------------------------------------------
  Future<List<Assignment>> getAssignments() async {
    await init();
    final jsonStr = _prefs?.getString(AppConstants.keyAssignments);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((a) => Assignment.fromMap(a as Map<String, dynamic>)).toList();
      } catch (e) {
        return MockDataService.getInitialAssignments();
      }
    }
    final initial = MockDataService.getInitialAssignments();
    await saveAssignments(initial);
    return initial;
  }

  Future<void> saveAssignments(List<Assignment> assignments) async {
    await init();
    final list = assignments.map((a) => a.toMap()).toList();
    await _prefs?.setString(AppConstants.keyAssignments, jsonEncode(list));
  }

  Future<void> toggleAssignmentSubmission(String assignmentId) async {
    final assignments = await getAssignments();
    final index = assignments.indexWhere((a) => a.id == assignmentId);
    if (index != -1) {
      assignments[index].toggleSubmission();
      await saveAssignments(assignments);
    }
  }

  // -------------------------------------------------------------
  // EVENTS
  // -------------------------------------------------------------
  Future<List<UniversityEvent>> getEvents() async {
    await init();
    final jsonStr = _prefs?.getString(AppConstants.keyEvents);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((e) => UniversityEvent.fromMap(e as Map<String, dynamic>)).toList();
      } catch (e) {
        return MockDataService.getInitialEvents();
      }
    }
    final initial = MockDataService.getInitialEvents();
    await saveEvents(initial);
    return initial;
  }

  Future<void> saveEvents(List<UniversityEvent> events) async {
    await init();
    final list = events.map((e) => e.toMap()).toList();
    await _prefs?.setString(AppConstants.keyEvents, jsonEncode(list));
  }

  Future<void> toggleEventInterest(String eventId) async {
    final events = await getEvents();
    final index = events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      events[index].toggleInterest();
      await saveEvents(events);
    }
  }

  // -------------------------------------------------------------
  // NOTIFICATIONS
  // -------------------------------------------------------------
  Future<List<AppNotification>> getNotifications() async {
    await init();
    final jsonStr = _prefs?.getString(AppConstants.keyNotifications);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((n) => AppNotification.fromMap(n as Map<String, dynamic>)).toList();
      } catch (e) {
        return MockDataService.getInitialNotifications();
      }
    }
    final initial = MockDataService.getInitialNotifications();
    await saveNotifications(initial);
    return initial;
  }

  Future<void> saveNotifications(List<AppNotification> notifs) async {
    await init();
    final list = notifs.map((n) => n.toMap()).toList();
    await _prefs?.setString(AppConstants.keyNotifications, jsonEncode(list));
  }

  Future<void> markNotificationAsRead(String id) async {
    final list = await getNotifications();
    final index = list.indexWhere((n) => n.id == id);
    if (index != -1) {
      list[index].markAsRead();
      await saveNotifications(list);
    }
  }

  Future<void> markAllNotificationsRead() async {
    final list = await getNotifications();
    for (var n in list) {
      n.isRead = true;
    }
    await saveNotifications(list);
  }

  // -------------------------------------------------------------
  // NOTES (Practical 6: SQLite Database via DatabaseService)
  // -------------------------------------------------------------
  Future<List<Note>> getNotes({String query = '', String sortBy = 'date_desc'}) async {
    return await DatabaseService().getNotes(query: query, sortBy: sortBy);
  }

  Future<void> addNote(Note note) async {
    await DatabaseService().insertNote(note);
  }

  Future<void> updateNote(Note note) async {
    await DatabaseService().updateNote(note);
  }

  Future<void> deleteNote(String id) async {
    await DatabaseService().deleteNote(id);
  }

  // -------------------------------------------------------------
  // ASSIGNMENTS & TASKS (Practical 6: SQLite Database)
  // -------------------------------------------------------------
  Future<void> addAssignment(Assignment asg) async {
    await DatabaseService().insertAssignment(asg);
  }

  Future<void> updateAssignment(Assignment asg) async {
    await DatabaseService().updateAssignment(asg);
  }

  Future<void> deleteAssignment(String id) async {
    await DatabaseService().deleteAssignment(id);
  }
}
