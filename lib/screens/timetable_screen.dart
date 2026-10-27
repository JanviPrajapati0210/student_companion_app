import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

// Practical 3 – Responsive Timetable UI
// - Uses LayoutBuilder, MediaQuery, Row, Column, Expanded, SingleChildScrollView
// - Responsive adaptation for small phones vs tablets/landscape

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  int _selectedDayIndex = 0;

  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  final Map<int, List<Map<String, String>>> _scheduleData = {
    0: [
      {'time': '09:15 - 10:15 AM', 'code': 'CS401', 'name': 'Design & Analysis of Algorithms', 'room': 'LH 204', 'type': 'Lecture', 'faculty': 'Dr. Rajesh Patel'},
      {'time': '10:30 - 11:30 AM', 'code': 'CS403', 'name': 'Database Management Systems', 'room': 'LH 204', 'type': 'Lecture', 'faculty': 'Dr. Vivek Mehta'},
      {'time': '11:45 - 01:15 PM', 'code': 'AI402', 'name': 'Deep Learning Lab', 'room': 'Comp Lab 4', 'type': 'Lab Practical', 'faculty': 'Prof. Ananya Sharma'},
      {'time': '02:00 - 03:00 PM', 'code': 'SE404', 'name': 'Mobile Application Development', 'room': 'LH 102', 'type': 'Lecture', 'faculty': 'Prof. Sneha Joshi'},
    ],
    1: [
      {'time': '09:15 - 10:45 AM', 'code': 'AI402', 'name': 'Deep Learning & Neural Networks', 'room': 'LH 204', 'type': 'Lecture', 'faculty': 'Prof. Ananya Sharma'},
      {'time': '11:00 - 12:30 PM', 'code': 'EL405', 'name': 'Cloud Computing & DevOps', 'room': 'LH 101', 'type': 'Lecture', 'faculty': 'Dr. Hardik Shah'},
      {'time': '01:30 - 03:30 PM', 'code': 'SE404', 'name': 'Flutter Mobile Dev Lab', 'room': 'Mobile Lab 2', 'type': 'Lab Practical', 'faculty': 'Prof. Sneha Joshi'},
    ],
    2: [
      {'time': '09:15 - 10:15 AM', 'code': 'CS401', 'name': 'Design & Analysis of Algorithms', 'room': 'LH 204', 'type': 'Lecture', 'faculty': 'Dr. Rajesh Patel'},
      {'time': '10:30 - 12:00 PM', 'code': 'CS403', 'name': 'DBMS SQL Query Lab', 'room': 'Database Lab', 'type': 'Lab Practical', 'faculty': 'Dr. Vivek Mehta'},
      {'time': '01:30 - 02:30 PM', 'code': 'SE404', 'name': 'Mobile Application Development', 'room': 'LH 102', 'type': 'Lecture', 'faculty': 'Prof. Sneha Joshi'},
      {'time': '02:45 - 03:45 PM', 'code': 'EL406', 'name': 'Cyber Security', 'room': 'LH 101', 'type': 'Elective', 'faculty': 'Prof. Rohan Desai'},
    ],
    3: [
      {'time': '09:15 - 10:45 AM', 'code': 'AI402', 'name': 'Deep Learning & Neural Networks', 'room': 'LH 204', 'type': 'Lecture', 'faculty': 'Prof. Ananya Sharma'},
      {'time': '11:00 - 12:00 PM', 'code': 'CS403', 'name': 'Database Management Systems', 'room': 'LH 204', 'type': 'Lecture', 'faculty': 'Dr. Vivek Mehta'},
      {'time': '01:30 - 03:00 PM', 'code': 'CS401', 'name': 'Algorithms Coding Practice', 'room': 'Comp Lab 1', 'type': 'Tutorial', 'faculty': 'Dr. Rajesh Patel'},
    ],
    4: [
      {'time': '09:15 - 10:15 AM', 'code': 'CS401', 'name': 'Design & Analysis of Algorithms', 'room': 'LH 204', 'type': 'Lecture', 'faculty': 'Dr. Rajesh Patel'},
      {'time': '10:30 - 12:00 PM', 'code': 'EL405', 'name': 'DevOps & Docker Containers', 'room': 'Cloud Center', 'type': 'Lab Practical', 'faculty': 'Dr. Hardik Shah'},
      {'time': '01:30 - 03:00 PM', 'code': 'SE404', 'name': 'Mobile Application Development', 'room': 'LH 102', 'type': 'Lecture', 'faculty': 'Prof. Sneha Joshi'},
      {'time': '03:15 - 04:30 PM', 'code': 'SEM', 'name': 'Student Seminar & Mentorship', 'room': 'Auditorium', 'type': 'Activity', 'faculty': 'Class Counselor'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    final currentSlots = _scheduleData[_selectedDayIndex] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Academic Timetable'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Day Selection Row / ScrollView
              Container(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_days.length, (index) {
                      final isSelected = _selectedDayIndex == index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(_days[index]),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedDayIndex = index);
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // Timetable Slots List / Grid
              Expanded(
                child: currentSlots.isEmpty
                    ? const Center(child: Text('No classes scheduled for this day.'))
                    : isWide
                        ? GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: currentSlots.length,
                            itemBuilder: (context, i) => _buildSlotCard(currentSlots[i], isDark),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: currentSlots.length,
                            itemBuilder: (context, i) => _buildSlotCard(currentSlots[i], isDark),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSlotCard(Map<String, String> slot, bool isDark) {
    final isLab = slot['type']?.contains('Lab') ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLab ? Colors.purple.withOpacity(0.3) : (isDark ? const Color(0xFF334155) : Colors.grey.shade200),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isLab ? Colors.purple.withOpacity(0.12) : AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        slot['code']!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isLab ? Colors.purple : AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        slot['type']!,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                Text(
                  slot['time']!,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryLight),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              slot['name']!,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    slot['faculty']!,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.room_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(slot['room']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
