import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/university_event.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/empty_state.dart';

// Dart concept demonstration:
// - Category filtering with Enum & where()
// - Stateful toggle with animated heart / bookmark interaction
// - Date formatting and polymorphic summary getter

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final StorageService _storage = StorageService();
  bool _isLoading = true;
  List<UniversityEvent> _events = [];
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Cultural',
    'Workshop',
    'Seminar',
    'Exam',
    'Sports',
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final data = await _storage.getEvents();
    if (mounted) {
      setState(() {
        _events = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleInterest(UniversityEvent event) async {
    await _storage.toggleEventInterest(event.id);
    final updated = await _storage.getEvents();
    if (mounted) {
      setState(() {
        _events = updated;
      });

      final isSaved = !event.isInterested;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSaved ? 'Event "${event.title}" saved to your calendar!' : 'Event removed from saved list.',
          ),
          backgroundColor: isSaved ? AppTheme.primaryBlue : Colors.grey.shade800,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  List<UniversityEvent> get _filteredEvents {
    if (_selectedCategory == 'All') return _events;
    return _events.where((e) => e.categoryName.toLowerCase() == _selectedCategory.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Events & Seminars'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(cat),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppTheme.textDark,
                          ),
                          backgroundColor: Colors.white,
                          selectedColor: AppTheme.primaryBlue,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Events List
                Expanded(
                  child: _filteredEvents.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.event_busy,
                          title: 'No Events Found',
                          message: 'There are no events listed under the "$_selectedCategory" category right now.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          itemCount: _filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = _filteredEvents[index];
                            final dateFormatted = DateFormat('EEE, MMM d, yyyy').format(event.eventDateTime);
                            final timeFormatted = DateFormat('h:mm a').format(event.eventDateTime);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 14),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            event.categoryName.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryBlue,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            event.isInterested ? Icons.bookmark : Icons.bookmark_border,
                                            color: event.isInterested ? AppTheme.primaryBlue : Colors.grey,
                                          ),
                                          onPressed: () => _toggleInterest(event),
                                          tooltip: event.isInterested ? 'Remove from Saved' : 'Save Event',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      event.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      event.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_month, size: 14, color: AppTheme.primaryLight),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$dateFormatted • $timeFormatted',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          event.venue,
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                        ),
                                        const Spacer(),
                                        Text(
                                          'By ${event.organizer}',
                                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
