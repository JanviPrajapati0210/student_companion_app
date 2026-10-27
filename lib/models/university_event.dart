// Dart concept demonstration:
// - Inheritance: Abstract Event base class with concrete UniversityEvent
// - Method overriding (@override)
// - Polymorphic behavior

abstract class BaseCalendarItem {
  final String id;
  final String title;
  final DateTime eventDateTime;

  BaseCalendarItem({
    required this.id,
    required this.title,
    required this.eventDateTime,
  });

  String get summary;
}

enum EventCategory {
  seminar,
  workshop,
  examination,
  cultural,
  sports,
}

class UniversityEvent extends BaseCalendarItem {
  final String venue;
  final String description;
  final String organizer;
  final EventCategory category;
  bool isInterested;

  UniversityEvent({
    required super.id,
    required super.title,
    required super.eventDateTime,
    required this.venue,
    required this.description,
    required this.organizer,
    required this.category,
    this.isInterested = false,
  });

  @override
  String get summary => '$title at $venue on ${eventDateTime.day}/${eventDateTime.month}';

  String get categoryName {
    switch (category) {
      case EventCategory.seminar:
        return 'Seminar';
      case EventCategory.workshop:
        return 'Workshop';
      case EventCategory.examination:
        return 'Exam';
      case EventCategory.cultural:
        return 'Cultural';
      case EventCategory.sports:
        return 'Sports';
    }
  }

  void toggleInterest() {
    isInterested = !isInterested;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'eventDateTime': eventDateTime.toIso8601String(),
      'venue': venue,
      'description': description,
      'organizer': organizer,
      'category': category.index,
      'isInterested': isInterested ? 1 : 0,
    };
  }

  factory UniversityEvent.fromMap(Map<String, dynamic> map) {
    return UniversityEvent(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      eventDateTime: DateTime.tryParse(map['eventDateTime'] ?? '') ?? DateTime.now(),
      venue: map['venue'] ?? '',
      description: map['description'] ?? '',
      organizer: map['organizer'] ?? 'University Student Council',
      category: EventCategory.values[map['category'] is int ? map['category'] : 0],
      isInterested: map['isInterested'] == 1 || map['isInterested'] == true,
    );
  }
}
