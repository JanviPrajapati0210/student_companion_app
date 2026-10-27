import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/storage_service.dart';
import 'home_dashboard_screen.dart';
import 'course_registration_screen.dart';
import 'attendance_screen.dart';
import 'profile_screen.dart';
import 'timetable_screen.dart';
import 'assignments_screen.dart';
import 'notes_screen.dart';
import 'faculty_screen.dart';
import 'event_gallery_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

// Practical 5 – Navigation & Preferences
// - Bottom Navigation Bar (Home, Courses, Attendance, Profile)
// - Navigation Drawer for all secondary modules
// - Back button handling with WillPopScope / PopScope
// - Working logout with confirmation dialog

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  final VoidCallback? onThemeChanged;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
    this.onThemeChanged,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  final StorageService _storage = StorageService();

  // Exactly 4 primary Bottom Navigation Screens (Practical 5 requirement)
  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    CourseRegistrationScreen(),
    AttendanceScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to sign out from the Smart Student Companion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () async {
              await _storage.logout();
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvoked: (didPop) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getAppBarTitle(_currentIndex),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            // Quick access to Notifications
            IconButton(
              tooltip: 'Notifications',
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),
            // Quick access to Settings
            IconButton(
              tooltip: 'Settings & Preferences',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(onThemeChanged: widget.onThemeChanged),
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ),

        // Navigation Drawer (Practical 5 requirement)
        drawer: Drawer(
          child: Column(
            children: [
              // Drawer User Accounts Header
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                accountName: const Text(
                  'Alex Morgan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                accountEmail: const Text(
                  '24AIML052 • alex.morgan@charusat.edu.in',
                  style: TextStyle(fontSize: 12),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    'A',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                  ),
                ),
              ),

              // Drawer Navigation Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.dashboard_outlined),
                      title: const Text('Dashboard Home'),
                      selected: _currentIndex == 0,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _currentIndex = 0);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.menu_book_outlined),
                      title: const Text('Course Registration'),
                      selected: _currentIndex == 1,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _currentIndex = 1);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.fact_check_outlined),
                      title: const Text('Attendance Tracker'),
                      selected: _currentIndex == 2,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _currentIndex = 2);
                      },
                    ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text('ACADEMIC MODULES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_view_week, color: AppTheme.primaryLight),
                      title: const Text('Timetable & Schedule'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TimetableScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.task_alt, color: Color(0xFFD97706)),
                      title: const Text('Assignments (SQLite)'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AssignmentsScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit_note, color: Color(0xFF0284C7)),
                      title: const Text('Study Notes (SQLite)'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotesScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.badge_outlined, color: Color(0xFF7C3AED)),
                      title: const Text('Faculty Directory'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FacultyScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library_outlined, color: Color(0xFFEA580C)),
                      title: const Text('Campus Event Gallery'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EventGalleryScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications_none, color: Color(0xFF16A34A)),
                      title: const Text('Campus Alerts & Notices'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('Preferences & Theme'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(onThemeChanged: widget.onThemeChanged),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Bottom Logout in Drawer
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.errorRed),
                title: const Text('Log Out', style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _handleLogout();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),

        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),

        // 4 Bottom Navigation Bar items (Practical 5)
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: isDark ? AppTheme.primaryLight : AppTheme.primaryBlue,
          unselectedItemColor: Colors.grey.shade500,
          selectedFontSize: 11.5,
          unselectedFontSize: 10.5,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Courses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fact_check_outlined),
              activeIcon: Icon(Icons.fact_check),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Student Companion';
      case 1:
        return 'Course Registration';
      case 2:
        return 'Attendance Tracker';
      case 3:
        return 'Student Profile';
      default:
        return 'Smart Student Companion';
    }
  }
}
