// Dart concept demonstration:
// - Enums and pattern matching / switch-case
// - DateTime manipulations and comparison (isBefore, isAfter)
// - Factory constructors and serialization

enum AssignmentStatus {
  pending,
  submitted,
  overdue,
}

class Assignment {
  final String id;
  final String title;
  final String subject;
  final String category; // Practical 6: Homework, Lab Report, Project, Quiz, Exam
  final String priority; // Practical 6: Low, Medium, High
  final String description;
  final DateTime dueDate;
  final int maxMarks;
  bool isSubmitted;
  DateTime? submittedAt;

  Assignment({
    required this.id,
    required this.title,
    required this.subject,
    this.category = 'Homework',
    this.priority = 'Medium',
    required this.description,
    required this.dueDate,
    this.maxMarks = 100,
    this.isSubmitted = false,
    this.submittedAt,
  });

  // Dynamic status evaluation using switch and conditionals
  AssignmentStatus get currentStatus {
    if (isSubmitted) {
      return AssignmentStatus.submitted;
    }
    if (DateTime.now().isAfter(dueDate)) {
      return AssignmentStatus.overdue;
    }
    return AssignmentStatus.pending;
  }

  // Helper string representation
  String get statusLabel {
    switch (currentStatus) {
      case AssignmentStatus.submitted:
        return 'Submitted';
      case AssignmentStatus.overdue:
        return 'Overdue';
      case AssignmentStatus.pending:
        return 'Pending';
    }
  }

  // Days left calculation using arithmetic
  int get daysRemaining {
    final difference = dueDate.difference(DateTime.now()).inDays;
    return difference;
  }

  void toggleSubmission() {
    isSubmitted = !isSubmitted;
    submittedAt = isSubmitted ? DateTime.now() : null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'category': category,
      'priority': priority,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'maxMarks': maxMarks,
      'isSubmitted': isSubmitted ? 1 : 0,
      'submittedAt': submittedAt?.toIso8601String(),
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      category: map['category'] ?? 'Homework',
      priority: map['priority'] ?? 'Medium',
      description: map['description'] ?? '',
      dueDate: DateTime.tryParse(map['dueDate'] ?? '') ?? DateTime.now().add(const Duration(days: 3)),
      maxMarks: map['maxMarks'] is int ? map['maxMarks'] : 100,
      isSubmitted: map['isSubmitted'] == 1 || map['isSubmitted'] == true,
      submittedAt: map['submittedAt'] != null ? DateTime.tryParse(map['submittedAt']) : null,
    );
  }
}
