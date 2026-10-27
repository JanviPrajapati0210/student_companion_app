// Dart concept demonstration:
// - Notification classification enum
// - Time-based sorting and read status updates

enum NotificationType {
  announcement,
  assignment,
  attendance,
  course,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  void markAsRead() {
    isRead = true;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.index,
      'isRead': isRead ? 1 : 0,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      type: NotificationType.values[map['type'] is int ? map['type'] : 0],
      isRead: map['isRead'] == 1 || map['isRead'] == true,
    );
  }
}
