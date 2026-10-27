import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/student.dart';
import '../models/attendance_record.dart';
import '../models/assignment.dart';
import '../models/course.dart';
import '../models/university_event.dart';
import '../models/app_notification.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/stat_card.dart';
import 'notes_screen.dart';
import 'events_screen.dart';
import 'notifications_screen.dart';
import 'timetable_screen.dart';
import 'attendance_screen.dart';
import 'course_registration_screen.dart';
import 'assignments_screen.dart';

// Practical 3 & 4 – Responsive Dashboard Screen
// - Uses LayoutBuilder, MediaQuery, Expanded, Flexible, Wrap, and responsive GridView
// - Fully responsive for mobile (< 600px), tablet, and desktop (>= 600px)
// - Prevents RenderFlex overflow, text clipping, and unintended horizontal scrolling

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final StorageService _storage = StorageService();

  bool _isLoading = true;
  Student? _student;
  List<AttendanceRecord> _attendance = [];
  List<Course> _courses = [];
  List<Assignment> _assignments = [];
  List<UniversityEvent> _events = [];
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final student = await _storage.getStudent();
      final attendance = await _storage.getAttendance();
      final courses = await _storage.getCourses();
      final assignments = await _storage.getAssignments();
      final events = await _storage.getEvents();
      final notifications = await _storage.getNotifications();

      if (mounted) {
        setState(() {
          _student = student;
          _attendance = attendance;
          _courses = courses;
          _assignments = assignments;
          _events = events;
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Calculate overall attendance percentage using loop and arithmetic
  double get _overallAttendancePercentage {
    if (_attendance.isEmpty) return 0.0;
    int totalClasses = 0;
    int totalAttended = 0;

    for (var record in _attendance) {
      totalClasses += record.totalClasses;
      totalAttended += record.attendedClasses;
    }

    if (totalClasses == 0) return 100.0;
    return (totalAttended / totalClasses) * 100.0;
  }

  int get _pendingAssignmentsCount {
    int count = 0;
    for (var a in _assignments) {
      if (!a.isSubmitted) count++;
    }
    return count;
  }

  int get _registeredCoursesCount {
    int count = 0;
    for (var c in _courses) {
      if (c.isRegistered) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final todayFormatted = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
    final studentName = _student?.name ?? 'Alex Morgan';
    final enrollmentNumber = _student?.enrollmentNumber ?? '24AIML052';
    final department = _student?.department ?? 'Computer Engineering';
    final semester = _student?.semester ?? 4;
    final hasShortage = _overallAttendancePercentage < 75.0;

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: LayoutBuilder(
        builder: (context, screenConstraints) {
          final isMobile = screenConstraints.maxWidth < 600;

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 20,
              vertical: 16,
            ),
            children: [
              // 1. Responsive Welcome Banner
              _buildResponsiveWelcomeBanner(
                studentName: studentName,
                enrollmentNumber: enrollmentNumber,
                department: department,
                semester: semester,
                todayFormatted: todayFormatted,
                isMobile: isMobile,
              ),

              const SizedBox(height: 16),

              // 2. Shortage Alert Banner (if attendance < 75%)
              if (hasShortage) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Attendance Warning (<75%)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF991B1B),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Your aggregate attendance is ${_overallAttendancePercentage.toStringAsFixed(1)}%. Minimum 75% is required for end-semester examinations.',
                              style: const TextStyle(
                                color: Color(0xFF7F1D1D),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AttendanceScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text('Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 3. Academic Summary Cards Grid Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Academic Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    'Live Term II',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Responsive Academic Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  int crossAxisCount;
                  double childAspectRatio;

                  if (width >= 960) {
                    crossAxisCount = 4;
                    childAspectRatio = 1.45;
                  } else if (width >= 600) {
                    crossAxisCount = 2;
                    childAspectRatio = 1.42;
                  } else if (width >= 350) {
                    // Mobile phones: 2 columns with generous vertical height
                    crossAxisCount = 2;
                    childAspectRatio = 1.15;
                  } else {
                    // Very narrow mobile phones (< 350px)
                    crossAxisCount = 1;
                    childAspectRatio = 2.4;
                  }

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: childAspectRatio,
                    children: [
                      StatCard(
                        title: 'Overall Attendance',
                        value: '${_overallAttendancePercentage.toStringAsFixed(1)}%',
                        subtitle: hasShortage ? 'Below 75% Target' : 'Good Standing',
                        icon: Icons.pie_chart,
                        color: hasShortage ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AttendanceScreen()),
                          );
                        },
                      ),
                      StatCard(
                        title: 'Enrolled Courses',
                        value: '$_registeredCoursesCount',
                        subtitle: '${_registeredCoursesCount * 3.5} Credits',
                        icon: Icons.menu_book,
                        color: AppTheme.primaryLight,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CourseRegistrationScreen()),
                          );
                        },
                      ),
                      StatCard(
                        title: 'Pending Tasks',
                        value: '$_pendingAssignmentsCount',
                        subtitle: 'SQLite Database',
                        icon: Icons.pending_actions,
                        color: const Color(0xFFD97706),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AssignmentsScreen()),
                          );
                        },
                      ),
                      StatCard(
                        title: 'Study Notes',
                        value: '${_events.length}',
                        subtitle: 'Full CRUD & Search',
                        icon: Icons.edit_note,
                        color: const Color(0xFF9333EA),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotesScreen()),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 22),

              // 4. Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    'Direct Shortcuts',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Responsive Action Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 600;

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            context,
                            icon: Icons.calendar_view_week,
                            label: 'Timetable',
                            color: const Color(0xFF2563EB),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TimetableScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuickActionButton(
                            context,
                            icon: Icons.edit_note,
                            label: 'My Notes',
                            color: const Color(0xFF0284C7),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const NotesScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuickActionButton(
                            context,
                            icon: Icons.campaign,
                            label: 'Notices',
                            color: const Color(0xFF7C3AED),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuickActionButton(
                            context,
                            icon: Icons.celebration,
                            label: 'Events',
                            color: const Color(0xFFEA580C),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const EventsScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  // Mobile 2x2 grid for action buttons
                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.1,
                    children: [
                      _buildQuickActionButton(
                        context,
                        icon: Icons.calendar_view_week,
                        label: 'Timetable',
                        color: const Color(0xFF2563EB),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TimetableScreen()),
                          );
                        },
                      ),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.edit_note,
                        label: 'My Notes',
                        color: const Color(0xFF0284C7),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotesScreen()),
                          );
                        },
                      ),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.campaign,
                        label: 'Notices',
                        color: const Color(0xFF7C3AED),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                          );
                        },
                      ),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.celebration,
                        label: 'Events',
                        color: const Color(0xFFEA580C),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EventsScreen()),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // 5. Timetable & Announcements (Stacked on mobile < 700px, Side-by-Side on tablet/laptop)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMultiColumn = constraints.maxWidth >= 720;

                  final timetableWidget = _buildTimetablePreview(context);
                  final announcementsWidget = _buildAnnouncementsPreview(context);

                  if (isMultiColumn) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: timetableWidget),
                        const SizedBox(width: 16),
                        Expanded(child: announcementsWidget),
                      ],
                    );
                  }

                  // Mobile layout: Stacked vertically
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      timetableWidget,
                      const SizedBox(height: 20),
                      announcementsWidget,
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  // Responsive Welcome Banner Widget
  Widget _buildResponsiveWelcomeBanner({
    required String studentName,
    required String enrollmentNumber,
    required String department,
    required int semester,
    required String todayFormatted,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 15 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Welcome text, student info & avatar
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to your student companion',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      studentName,
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$department • Sem $semester',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: isMobile ? 22 : 26,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  studentName.isNotEmpty ? studentName[0] : 'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Bottom info badges using Wrap to allow elegant line breaking without overlapping
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Enrollment number chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.badge_outlined, size: 13, color: Colors.white.withOpacity(0.9)),
                    const SizedBox(width: 5),
                    Text(
                      enrollmentNumber,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Date badge chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      todayFormatted,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Timetable Preview Section
  Widget _buildTimetablePreview(BuildContext context) {
    final registeredCourses = _courses.where((c) => c.isRegistered).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'Today\'s Class Schedule',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TimetableScreen()),
                );
              },
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 6),

        if (registeredCourses.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Text('No registered courses scheduled for today.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          )
        else
          ...registeredCourses.map((course) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0.8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      course.code.substring(0, 2),
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  course.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${course.schedule} • ${course.room}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 11, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TimetableScreen()),
                  );
                },
              ),
            );
          }),
      ],
    );
  }

  // Campus Announcements Preview Section
  Widget _buildAnnouncementsPreview(BuildContext context) {
    final recentNotifs = _notifications.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'Campus Announcements',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 6),

        if (recentNotifs.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Text('No announcements at this time.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          )
        else
          ...recentNotifs.map((notif) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0.8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.campaign, color: Color(0xFF7C3AED), size: 20),
                  ),
                ),
                title: Text(
                  notif.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  notif.message,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 11, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
            );
          }),
      ],
    );
  }

  // Quick Action Button
  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
