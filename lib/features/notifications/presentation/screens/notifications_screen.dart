import 'package:flutter/material.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _service,
      builder: (context, _) {
        final notifications = _service.notifications;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: AppColors.textSecondary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'الإشعارات',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            actions: [
              if (_service.unreadCount > 0)
                TextButton(
                  onPressed: () => _service.markAllAsRead(),
                  child: const Text(
                    'قراءة الكل',
                    style: TextStyle(
                        color: AppColors.primary, fontSize: 13),
                  ),
                ),
            ],
          ),
          body: notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none_rounded,
                          color: AppColors.textMuted, size: 60),
                      SizedBox(height: 12),
                      Text(
                        'لا توجد إشعارات',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    return Dismissible(
                      key: Key(n.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: Colors.redAccent),
                      ),
                      onDismissed: (_) => _service.remove(n.id),
                      child: GestureDetector(
                        onTap: () => _service.markAsRead(n.id),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: n.isRead
                                ? AppColors.cardBg
                                : AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: n.isRead
                                  ? AppColors.border
                                  : AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _typeColor(n.type)
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _typeIcon(n.type),
                                  color: _typeColor(n.type),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      n.title,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: n.isRead
                                            ? FontWeight.w400
                                            : FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      n.body,
                                      textDirection: TextDirection.rtl,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(n.time),
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!n.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(left: 8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
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
      },
    );
  }

  Color _typeColor(NotificationType type) {
    switch (type) {
      case NotificationType.workout:
        return AppColors.primary;
      case NotificationType.achievement:
        return AppColors.accentOrange;
      case NotificationType.reminder:
        return AppColors.accentGreen;
      case NotificationType.system:
        return AppColors.textSecondary;
    }
  }

  IconData _typeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.workout:
        return Icons.fitness_center_rounded;
      case NotificationType.achievement:
        return Icons.emoji_events_rounded;
      case NotificationType.reminder:
        return Icons.alarm_rounded;
      case NotificationType.system:
        return Icons.info_outline_rounded;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
