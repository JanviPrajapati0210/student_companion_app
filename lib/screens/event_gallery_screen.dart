import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

// Practical 3 – Responsive Event Gallery Screen
// - Uses LayoutBuilder, MediaQuery, dynamic GridView columns
// - Portrait / landscape support with smooth card animations

class EventGalleryScreen extends StatefulWidget {
  const EventGalleryScreen({super.key});

  @override
  State<EventGalleryScreen> createState() => _EventGalleryScreenState();
}

class _EventGalleryScreenState extends State<EventGalleryScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Hackathon', 'TechFest', 'Cultural', 'Sports', 'Workshops'];

  final List<Map<String, dynamic>> _galleryItems = [
    {
      'title': 'Cognizance 2026 Hackathon',
      'category': 'Hackathon',
      'date': 'Oct 23, 2026',
      'attendees': '850+ Participants',
      'icon': Icons.code_rounded,
      'color': Colors.blue,
      'description': '36-hour state-level hackathon with AI, Web3, and Mobile app tracks. Keynotes by tech industry experts.',
    },
    {
      'title': 'Flutter & GenAI Workshop',
      'category': 'Workshops',
      'date': 'Oct 27, 2026',
      'attendees': '240 Students',
      'icon': Icons.phone_android_rounded,
      'color': Colors.indigo,
      'description': 'Hands-on practical session building cross-platform Flutter applications with Gemini AI SDK integration.',
    },
    {
      'title': 'Vrundavan Annual Cultural Night',
      'category': 'Cultural',
      'date': 'Nov 12, 2026',
      'attendees': '3200+ Students',
      'icon': Icons.music_note_rounded,
      'color': Colors.pink,
      'description': 'Annual cultural extravaganza featuring classical dance, band battle, fashion show, and celebrity guest DJ.',
    },
    {
      'title': 'Inter-College Sports Championship',
      'category': 'Sports',
      'date': 'Nov 15, 2026',
      'attendees': '40 Teams',
      'icon': Icons.sports_volleyball_rounded,
      'color': Colors.amber,
      'description': 'Football, basketball, cricket, and badminton tournaments hosted at the university sports complex.',
    },
    {
      'title': 'RoboWars & Drone Racing Arena',
      'category': 'TechFest',
      'date': 'Oct 24, 2026',
      'attendees': '600+ Spectators',
      'icon': Icons.smart_toy_outlined,
      'color': Colors.teal,
      'description': 'Combat robotics arena and indoor drone obstacle obstacle course speed challenge.',
    },
    {
      'title': 'Cloud DevOps BootCamp',
      'category': 'Workshops',
      'date': 'Nov 02, 2026',
      'attendees': '180 Developers',
      'icon': Icons.cloud_outlined,
      'color': Colors.deepOrange,
      'description': 'Containerization with Docker, Kubernetes cluster orchestration, and automated CI/CD pipelines.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _selectedCategory == 'All'
        ? _galleryItems
        : _galleryItems.where((item) => item['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Event Gallery'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          // Dynamic crossAxisCount based on screen width:
          // Phone: 2 columns, Tablet: 3 columns, Desktop/Wide landscape: 4 columns
          int columns = 2;
          if (width > 900) {
            columns = 4;
          } else if (width > 600) {
            columns = 3;
          }

          return Column(
            children: [
              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cat),
                        selectedColor: AppTheme.primaryBlue,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          setState(() => _selectedCategory = cat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Responsive Event Gallery Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final Color color = item['color'];

                    return InkWell(
                      onTap: () => _showEventDetailsModal(context, item),
                      borderRadius: BorderRadius.circular(16),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Gallery Card Visual Banner
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [color.withOpacity(0.85), color],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Icon(item['icon'], size: 48, color: Colors.white.withOpacity(0.9)),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black38,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item['category'],
                                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Details
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item['title'],
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item['date'],
                                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                        Text(
                                          item['attendees'],
                                          style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEventDetailsModal(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(item['category']),
                    backgroundColor: item['color'].withOpacity(0.15),
                    labelStyle: TextStyle(color: item['color'], fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item['title'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(item['date'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 16),
                  const Icon(Icons.group, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(item['attendees'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                item['description'],
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registered interest for ${item['title']}!')),
                  );
                },
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Save to My Activity Calendar'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
