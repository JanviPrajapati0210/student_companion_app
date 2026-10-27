import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_notification.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/empty_state.dart';

// Dart concept demonstration:
// - Stateful manipulation of notification lists
// - Switch statement for NotificationType icons and colors
// - Batch operations (mark all read)

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final StorageService _storage = StorageService();
  bool _isLoading = true;
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final data = await _storage.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String id) async {
    await _storage.markNotificationAsRead(id);
    _loadNotifications();
  }

  Future<void> _markAllRead() async {
    await _storage.markAllNotificationsRead();
    _loadNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.notifications_off_outlined,
                  title: 'No Notifications',
                  message: 'You have caught up with all campus alerts and messages.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    final timeAgo = DateFormat('MMM d • h:mm a').format(item.timestamp);

                    IconData icon;
                    Color color;

                    switch (item.type) {
                      case NotificationType.attendance:
                        icon = Icons.warning_amber_rounded;
                        color = AppTheme.errorRed;
                        break;
                      case NotificationType.assignment:
                        icon = Icons.assignment_late_outlined;
                        color = AppTheme.warningAmber;
                        break;
                      case NotificationType.course:
                        icon = Icons.menu_book;
                        color = AppTheme.primaryLight;
                        break;
                      case NotificationType.announcement:
                        icon = Icons.campaign_outlined;
                        color = const Color(0xFF9333EA);
                        break;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: item.isRead ? 0.5 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: item.isRead ? Colors.grey.shade200 : AppTheme.primaryBlue.withOpacity(0.3),
                          width: item.isRead ? 1 : 1.5,
                        ),
                      ),
                      color: item.isRead ? Colors.white : const Color(0xFFF0F7FF),
                      child: InkWell(
                        onTap: () {
                          if (!item.isRead) {
                            _markAsRead(item.id);
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, color: color, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                              fontSize: 14,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                        ),
                                        if (!item.isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppTheme.primaryBlue,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.message,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      timeAgo,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
