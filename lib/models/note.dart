// Dart concept demonstration:
// - Object creation, copyWith immutability method
// - Optional parameters, null safety
// - List of strings for tags, JSON mapping

class Note {
  final String id;
  String title;
  String subject;
  String category; // Practical 6: Lecture, Lab, Summary, Exam Prep, General
  String description;
  final DateTime createdAt;
  DateTime updatedAt;
  int colorValue; // Color hex integer for colorful cards

  Note({
    required this.id,
    required this.title,
    required this.subject,
    this.category = 'General',
    required this.description,
    required this.createdAt,
    DateTime? updatedAt,
    this.colorValue = 0xFFE0F2FE, // Light blue accent default
  }) : updatedAt = updatedAt ?? createdAt;

  // Named constructor for a fresh blank note
  Note.fresh({required this.subject, this.category = 'General'})
      : id = 'note_${DateTime.now().millisecondsSinceEpoch}',
        title = '',
        description = '',
        createdAt = DateTime.now(),
        updatedAt = DateTime.now(),
        colorValue = 0xFFE0F2FE;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'category': category,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'colorValue': colorValue,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? 'note_0',
      title: map['title'] ?? '',
      subject: map['subject'] ?? 'General',
      category: map['category'] ?? 'General',
      description: map['description'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      colorValue: map['colorValue'] is int ? map['colorValue'] : 0xFFE0F2FE,
    );
  }

  Note copyWith({
    String? title,
    String? subject,
    String? category,
    String? description,
    int? colorValue,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
