import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final NotificationType type;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType { workout, achievement, reminder, system }

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    _seedNotifications();
  }

  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void _seedNotifications() {
    _notifications.addAll([
      AppNotification(
        id: 'n1',
        title: 'حان وقت التمرين! 💪',
        body: 'لديك تمرين عضلات الصدر اليوم. لا تفوّته!',
        time: DateTime.now().subtract(const Duration(minutes: 10)),
        type: NotificationType.reminder,
      ),
      AppNotification(
        id: 'n2',
        title: 'إنجاز جديد 🏆',
        body: 'أكملت 7 أيام متتالية من التمارين. أنت رائع!',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.achievement,
      ),
      AppNotification(
        id: 'n3',
        title: 'تمرين اليوم جاهز',
        body: 'تمرين الظهر والبايسبس - 45 دقيقة',
        time: DateTime.now().subtract(const Duration(hours: 5)),
        type: NotificationType.workout,
        isRead: true,
      ),
    ]);
  }

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void remove(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
