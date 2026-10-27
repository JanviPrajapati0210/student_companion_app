import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/empty_state.dart';

// Dart concept demonstration:
// - TabController for separate Registered vs Available views
// - List filtering (where, toList)
// - Validation against duplicate registration and credit limits
// - Asynchronous data persistence

class CourseRegistrationScreen extends StatefulWidget {
  const CourseRegistrationScreen({super.key});

  @override
  State<CourseRegistrationScreen> createState() => _CourseRegistrationScreenState();
}

class _CourseRegistrationScreenState extends State<CourseRegistrationScreen> with SingleTickerProviderStateMixin {
  final StorageService _storage = StorageService();
  late TabController _tabController;
  bool _isLoading = true;
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCourses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    final data = await _storage.getCourses();
    if (mounted) {
      setState(() {
        _courses = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleRegistration(Course course) async {
    final willRegister = !course.isRegistered;

    // Optional credit calculation validation: maximum 24 credits per semester
    if (willRegister) {
      int currentRegisteredCredits = _courses
          .where((c) => c.isRegistered)
          .fold(0, (sum, item) => sum + item.credits);

      if (currentRegisteredCredits + course.credits > 24) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot register: Maximum limit of 24 credits exceeded.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return;
      }
    }

    final newStatus = await _storage.toggleCourseRegistration(course.code);
    final updated = await _storage.getCourses();

    if (mounted) {
      setState(() {
        _courses = updated;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? 'Successfully registered for ${course.name}!'
                : 'Unregistered from ${course.name}.',
          ),
          backgroundColor: newStatus ? AppTheme.successGreen : AppTheme.warningAmber,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final registeredList = _courses.where((c) => c.isRegistered).toList();
    final availableList = _courses.where((c) => !c.isRegistered).toList();

    int totalCredits = registeredList.fold(0, (sum, c) => sum + c.credits);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryBlue,
            unselectedLabelColor: AppTheme.textMuted,
            indicatorColor: AppTheme.primaryBlue,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Registered (${registeredList.length})'),
              Tab(text: 'Available Catalog (${availableList.length})'),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Credit Tracker Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.primaryContainer.withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded, size: 18, color: AppTheme.primaryBlue),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Credits: $totalCredits / 24',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${24 - totalCredits} credits left',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Registered Courses Tab
                registeredList.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.menu_book,
                        title: 'No Registered Courses',
                        message: 'Switch to the Available Catalog tab to explore and enroll in university subjects.',
                        buttonText: 'Browse Catalog',
                        onButtonPressed: () {
                          _tabController.animateTo(1);
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: registeredList.length,
                        itemBuilder: (context, index) {
                          return _buildCourseCard(registeredList[index], isRegisteredView: true);
                        },
                      ),

                // 2. Available Catalog Tab
                availableList.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.check_circle_outline,
                        title: 'All Courses Registered',
                        message: 'You have enrolled in all available courses for this semester.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: availableList.length,
                        itemBuilder: (context, index) {
                          return _buildCourseCard(availableList[index], isRegisteredView: false);
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course, {required bool isRegisteredView}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.code,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${course.credits} Credits',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: course.isRegistered ? const Color(0xFFF0FDF4) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    course.isRegistered ? 'Enrolled' : 'Open',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: course.isRegistered ? AppTheme.successGreen : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              course.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Faculty: ${course.faculty}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 6),
            Text(
              course.description,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  course.schedule,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const Spacer(),
                Icon(Icons.room, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  course.room,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isRegisteredView)
                  OutlinedButton.icon(
                    onPressed: () => _showDropConfirmation(course),
                    icon: const Icon(Icons.remove_circle_outline, size: 16, color: AppTheme.errorRed),
                    label: const Text('Drop Course', style: TextStyle(color: AppTheme.errorRed, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => _toggleRegistration(course),
                    icon: const Icon(Icons.add_task, size: 16),
                    label: const Text('Register Course', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDropConfirmation(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unregister Course?'),
        content: Text('Are you sure you want to drop "${course.name}"? You can re-register from the catalog.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () {
              Navigator.pop(context);
              _toggleRegistration(course);
            },
            child: const Text('Confirm Drop'),
          ),
        ],
      ),
    );
  }
}
