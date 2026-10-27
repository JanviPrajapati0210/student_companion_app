// Dart concept demonstration:
// - Class hierarchy / composition
// - Final fields for immutable course entities
// - Methods, string interpolation, and boolean flags

class Course {
  final String code;
  final String name;
  final String faculty;
  final int credits;
  final String schedule;
  final String room;
  final String description;
  final bool isCore;
  bool isRegistered;

  Course({
    required this.code,
    required this.name,
    required this.faculty,
    required this.credits,
    required this.schedule,
    required this.room,
    required this.description,
    this.isCore = true,
    this.isRegistered = false,
  });

  // Formatted display helper
  String get fullInfo => '$code - $name ($credits Credits)';

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'faculty': faculty,
      'credits': credits,
      'schedule': schedule,
      'room': room,
      'description': description,
      'isCore': isCore ? 1 : 0,
      'isRegistered': isRegistered ? 1 : 0,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      faculty: map['faculty'] ?? '',
      credits: map['credits'] is int ? map['credits'] : 3,
      schedule: map['schedule'] ?? 'Mon, Wed 10:00 AM',
      room: map['room'] ?? 'Lab 302',
      description: map['description'] ?? '',
      isCore: map['isCore'] == 1 || map['isCore'] == true,
      isRegistered: map['isRegistered'] == 1 || map['isRegistered'] == true,
    );
  }
}
