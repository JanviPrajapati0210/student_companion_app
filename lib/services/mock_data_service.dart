import '../models/student.dart';
import '../models/course.dart';
import '../models/attendance_record.dart';
import '../models/assignment.dart';
import '../models/note.dart';
import '../models/university_event.dart';
import '../models/app_notification.dart';

// Dart concept demonstration:
// - Mock repository service with strongly-typed collections
// - DateTime instances, duration calculations

class MockDataService {
  static Student getInitialStudent() {
    return Student.initial();
  }

  static List<Course> getInitialCourses() {
    return [
      Course(
        code: 'CS401',
        name: 'Design and Analysis of Algorithms',
        faculty: 'Dr. Rajesh Patel',
        credits: 4,
        schedule: 'Mon, Wed, Fri 09:15 - 10:15 AM',
        room: 'Lecture Hall 204',
        description: 'Divide-and-conquer, dynamic programming, greedy algorithms, graph algorithms, NP-completeness.',
        isRegistered: true,
      ),
      Course(
        code: 'AI402',
        name: 'Deep Learning & Neural Networks',
        faculty: 'Prof. Ananya Sharma',
        credits: 4,
        schedule: 'Tue, Thu 10:30 - 12:00 PM',
        room: 'Computing Lab 4',
        description: 'Backpropagation, CNNs, RNNs, Transformers, computer vision, and NLP architectures.',
        isRegistered: true,
      ),
      Course(
        code: 'CS403',
        name: 'Database Management Systems',
        faculty: 'Dr. Vivek Mehta',
        credits: 3,
        schedule: 'Mon, Thu 02:00 - 03:30 PM',
        room: 'Seminar Hall 1',
        description: 'Relational algebra, SQL, indexing, transaction processing, concurrency control, and normalization.',
        isRegistered: true,
      ),
      Course(
        code: 'SE404',
        name: 'Mobile Application Development with Flutter',
        faculty: 'Prof. Sneha Joshi',
        credits: 3,
        schedule: 'Wed, Fri 01:30 - 03:00 PM',
        room: 'Mobile Dev Lab 2',
        description: 'Cross-platform app development using Flutter, Dart language concepts, state management, and SQLite.',
        isRegistered: true,
      ),
      Course(
        code: 'EL405',
        name: 'Cloud Computing & DevOps',
        faculty: 'Dr. Hardik Shah',
        credits: 3,
        schedule: 'Tue, Fri 03:30 - 05:00 PM',
        room: 'Cloud Center 101',
        description: 'Virtualization, Docker containers, Kubernetes, CI/CD pipelines, and AWS cloud architecture.',
        isRegistered: false,
      ),
      Course(
        code: 'EL406',
        name: 'Cyber Security & Ethical Hacking',
        faculty: 'Prof. Rohan Desai',
        credits: 3,
        schedule: 'Mon, Wed 03:30 - 05:00 PM',
        room: 'Security Lab 3',
        description: 'Network security protocols, vulnerability scanning, penetration testing, and digital forensics.',
        isRegistered: false,
      ),
    ];
  }

  static List<AttendanceRecord> getInitialAttendance() {
    return [
      AttendanceRecord(
        courseCode: 'CS401',
        courseName: 'Algorithms',
        totalClasses: 36,
        attendedClasses: 31, // ~86.1%
      ),
      AttendanceRecord(
        courseCode: 'AI402',
        courseName: 'Deep Learning',
        totalClasses: 28,
        attendedClasses: 24, // ~85.7%
      ),
      AttendanceRecord(
        courseCode: 'CS403',
        courseName: 'DBMS',
        totalClasses: 30,
        attendedClasses: 21, // 70.0% -> Shortage Warning!
      ),
      AttendanceRecord(
        courseCode: 'SE404',
        courseName: 'Mobile Dev (Flutter)',
        totalClasses: 24,
        attendedClasses: 22, // ~91.6%
      ),
    ];
  }

  static List<Assignment> getInitialAssignments() {
    final now = DateTime.now();
    return [
      Assignment(
        id: 'asg_1',
        title: 'Dynamic Programming - Knapsack Problem',
        subject: 'Algorithms (CS401)',
        category: 'Homework',
        priority: 'High',
        description: 'Implement 0/1 Knapsack and Fractional Knapsack algorithms with time complexity comparison analysis.',
        dueDate: now.add(const Duration(days: 2)),
        maxMarks: 50,
        isSubmitted: false,
      ),
      Assignment(
        id: 'asg_2',
        title: 'Flutter Student Companion UI & SQLite DB',
        subject: 'Mobile Dev (SE404)',
        category: 'Project',
        priority: 'High',
        description: 'Build complete student dashboard with attendance calculation, notes CRUD, and local storage.',
        dueDate: now.add(const Duration(days: 5)),
        maxMarks: 100,
        isSubmitted: false,
      ),
      Assignment(
        id: 'asg_3',
        title: 'SQL Normalization (1NF to BCNF) Case Study',
        subject: 'DBMS (CS403)',
        category: 'Lab Report',
        priority: 'Medium',
        description: 'Normalize university hospital database tables and verify lossless join decomposition.',
        dueDate: now.subtract(const Duration(days: 1)),
        maxMarks: 40,
        isSubmitted: true,
        submittedAt: now.subtract(const Duration(days: 2)),
      ),
      Assignment(
        id: 'asg_4',
        title: 'MNIST Digit Classification CNN Model',
        subject: 'Deep Learning (AI402)',
        category: 'Project',
        priority: 'High',
        description: 'Build and train a 3-layer Convolutional Neural Network achieving >98% test set accuracy.',
        dueDate: now.subtract(const Duration(days: 3)),
        maxMarks: 60,
        isSubmitted: false, // Overdue!
      ),
      Assignment(
        id: 'asg_5',
        title: 'Cloud Architecture & Microservices Quiz',
        subject: 'Cloud Computing (EL405)',
        category: 'Quiz',
        priority: 'Low',
        description: 'Prepare for 20 MCQ questions on Docker containerization and Kubernetes cluster concepts.',
        dueDate: now.add(const Duration(days: 7)),
        maxMarks: 25,
        isSubmitted: false,
      ),
    ];
  }

  static List<Note> getInitialNotes() {
    final now = DateTime.now();
    return [
      Note(
        id: 'note_1',
        title: 'Dart Object-Oriented Principles Quick Cheatsheet',
        subject: 'Mobile Dev (SE404)',
        category: 'Lecture Notes',
        description: 'Dart supports single inheritance, mixins, factory constructors, and named constructors. All types inherit from Object?. Private fields start with an underscore (_). Null safety prevents runtime NullPointer exceptions.',
        createdAt: now.subtract(const Duration(days: 3)),
        colorValue: 0xFFEFF6FF,
      ),
      Note(
        id: 'note_2',
        title: 'Dijkstra vs Bellman-Ford Shortest Path Notes',
        subject: 'Algorithms (CS401)',
        category: 'Exam Prep',
        description: 'Dijkstra works for non-negative edge weights in O(E log V). Bellman-Ford works with negative weights in O(V * E) and can detect negative weight cycles.',
        createdAt: now.subtract(const Duration(days: 6)),
        colorValue: 0xFFF0FDF4,
      ),
      Note(
        id: 'note_3',
        title: 'ACID Properties in Relational Databases',
        subject: 'DBMS (CS403)',
        category: 'Lecture Notes',
        description: 'Atomicity (all or nothing), Consistency (preserves database integrity constraints), Isolation (concurrent execution serializability), Durability (committed changes persist).',
        createdAt: now.subtract(const Duration(days: 8)),
        colorValue: 0xFFFEF3C7,
      ),
    ];
  }

  static List<UniversityEvent> getInitialEvents() {
    final now = DateTime.now();
    return [
      UniversityEvent(
        id: 'evt_1',
        title: 'Annual TechFest: Cognizance 2026',
        eventDateTime: now.add(const Duration(days: 8, hours: 4)),
        venue: 'University Central Auditorium',
        description: 'State-level 36-hour hackathon, robotics arena, coding challenges, and guest talks by industry leaders.',
        organizer: 'Faculty of Technology & Computer Applications',
        category: EventCategory.cultural,
        isInterested: true,
      ),
      UniversityEvent(
        id: 'evt_2',
        title: 'Hands-on Workshop: Generative AI with Flutter',
        eventDateTime: now.add(const Duration(days: 12, hours: 2)),
        venue: 'Advanced Research Lab 4',
        description: 'Learn to integrate LLMs, multi-modal features, and streaming responses into native Android apps.',
        organizer: 'Google Developer Student Club (GDSC)',
        category: EventCategory.workshop,
        isInterested: true,
      ),
      UniversityEvent(
        id: 'evt_3',
        title: 'Mid-Semester Examinations Commencement',
        eventDateTime: now.add(const Duration(days: 20)),
        venue: 'Academic Block B & C',
        description: 'Mid-term written examinations for all undergraduate engineering semesters. Hall tickets required.',
        organizer: 'Examination Cell',
        category: EventCategory.examination,
        isInterested: false,
      ),
      UniversityEvent(
        id: 'evt_4',
        title: 'Inter-College Football & Badminton Tournament',
        eventDateTime: now.add(const Duration(days: 15)),
        venue: 'Sports Complex Arena',
        description: 'Annual sports festival with 16 participating colleges across Gujarat state.',
        organizer: 'Sports Committee',
        category: EventCategory.sports,
        isInterested: false,
      ),
    ];
  }

  static List<AppNotification> getInitialNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'notif_1',
        title: 'Low Attendance Alert in DBMS',
        message: 'Your attendance in CS403 (DBMS) is 70.0%, which is below the mandatory 75% university requirement. Please contact Prof. Vivek Mehta.',
        timestamp: now.subtract(const Duration(hours: 3)),
        type: NotificationType.attendance,
        isRead: false,
      ),
      AppNotification(
        id: 'notif_2',
        title: 'New Assignment Posted: Knapsack Problem',
        message: 'Dr. Rajesh Patel posted Assignment 1 for Design & Analysis of Algorithms due in 2 days.',
        timestamp: now.subtract(const Duration(hours: 6)),
        type: NotificationType.assignment,
        isRead: false,
      ),
      AppNotification(
        id: 'notif_3',
        title: 'Course Registration Window Open',
        message: 'Elective course registration for Term II is currently active. Please verify your selected electives.',
        timestamp: now.subtract(const Duration(days: 1)),
        type: NotificationType.course,
        isRead: true,
      ),
      AppNotification(
        id: 'notif_4',
        title: 'TechFest Cognizance 2026 Registrations Open',
        message: 'Early bird registration for the 36-hour hackathon closes this Sunday. Register via the Events tab.',
        timestamp: now.subtract(const Duration(days: 2)),
        type: NotificationType.announcement,
        isRead: true,
      ),
    ];
  }
}
