import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

// Practical 3 – Responsive Faculty Information Screen
// - Uses LayoutBuilder, MediaQuery, GridView, TextField search, and AnimatedCard

class FacultyScreen extends StatefulWidget {
  const FacultyScreen({super.key});

  @override
  State<FacultyScreen> createState() => _FacultyScreenState();
}

class _FacultyScreenState extends State<FacultyScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _facultyList = [
    {
      'name': 'Dr. Rajesh Patel',
      'designation': 'Professor & Head of Department',
      'department': 'Computer Science & Engineering',
      'email': 'rajesh.patel@charusat.edu.in',
      'room': 'Cabin 204, Faculty Wing A',
      'hours': 'Mon, Wed 03:00 - 05:00 PM',
      'specialization': 'Algorithms, Complexity Theory, Graph Mining',
    },
    {
      'name': 'Prof. Ananya Sharma',
      'designation': 'Associate Professor',
      'department': 'Artificial Intelligence & Machine Learning',
      'email': 'ananya.sharma@charusat.edu.in',
      'room': 'Cabin 302, AI Research Wing',
      'hours': 'Tue, Thu 02:00 - 04:00 PM',
      'specialization': 'Deep Learning, Computer Vision, Transformers',
    },
    {
      'name': 'Dr. Vivek Mehta',
      'designation': 'Associate Professor',
      'department': 'Information Technology',
      'email': 'vivek.mehta@charusat.edu.in',
      'room': 'Cabin 112, IT Block',
      'hours': 'Wed, Fri 11:30 AM - 01:00 PM',
      'specialization': 'DBMS, Query Optimization, Distributed Databases',
    },
    {
      'name': 'Prof. Sneha Joshi',
      'designation': 'Assistant Professor',
      'department': 'Software Engineering',
      'email': 'sneha.joshi@charusat.edu.in',
      'room': 'Cabin 215, Mobile Computing Center',
      'hours': 'Daily 01:00 - 02:00 PM',
      'specialization': 'Cross-Platform Mobile Apps, Flutter, UX Design',
    },
    {
      'name': 'Dr. Hardik Shah',
      'designation': 'Associate Professor',
      'department': 'Cloud Computing & Systems',
      'email': 'hardik.shah@charusat.edu.in',
      'room': 'Cabin 108, Cloud Center',
      'hours': 'Tue, Fri 04:00 - 05:30 PM',
      'specialization': 'Cloud Architectures, DevOps, Kubernetes',
    },
    {
      'name': 'Prof. Rohan Desai',
      'designation': 'Assistant Professor',
      'department': 'Cyber Security',
      'email': 'rohan.desai@charusat.edu.in',
      'room': 'Cabin 318, Security Research Lab',
      'hours': 'Mon, Thu 03:30 - 04:30 PM',
      'specialization': 'Ethical Hacking, Network Protocols, Cryptography',
    },
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = _searchQuery.toLowerCase();

    final filtered = _facultyList.where((f) {
      return f['name']!.toLowerCase().contains(query) ||
          f['department']!.toLowerCase().contains(query) ||
          f['specialization']!.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Information & Directory'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search faculty by name, department, or domain...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Responsive Grid / List using LayoutBuilder
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 650;
                final crossAxisCount = isWide ? 2 : 1;

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No faculty members matched your search query.'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: isWide ? 1.9 : 1.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final faculty = filtered[i];
                    return Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppTheme.primaryContainer,
                                  child: Text(
                                    faculty['name']!.replaceAll(RegExp(r'^(Dr\.|Prof\.)\s*'), '').trim()[0],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlue,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        faculty['name']!,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        faculty['designation']!,
                                        style: const TextStyle(fontSize: 11, color: AppTheme.primaryLight, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        faculty['department']!,
                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 12),
                            Text(
                              'Specialization: ${faculty['specialization']!}',
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.meeting_room_outlined, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    faculty['room']!,
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.schedule, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  faculty['hours']!,
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                                const Spacer(),
                                Icon(Icons.email_outlined, size: 14, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 4),
                                Text(
                                  faculty['email']!.split('@')[0],
                                  style: TextStyle(fontSize: 10, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
