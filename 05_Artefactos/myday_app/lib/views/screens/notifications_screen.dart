import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../models/app_notification.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/date_formatter.dart';
import '../widgets/app_background.dart';
import '../widgets/guest_prompt.dart';
import '../widgets/round_icon_button.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.notificationController, required this.authController});

  final NotificationController notificationController;
  final AuthController authController;

  Future<void> _open(BuildContext context, AppNotification notification) async {
    notificationController.markAsRead(notification);

    final (route, arguments) = switch (notification.type) {
      NotificationType.message => (AppRoutes.chat, notification.target),
      NotificationType.comment => (AppRoutes.entryDetail, notification.target),
      NotificationType.groupReminder => (AppRoutes.groupDetail, notification.target),
      NotificationType.challenge => (AppRoutes.newEntry, null),
      NotificationType.streak => (AppRoutes.calendar, null),
    };

    if (route == AppRoutes.newEntry && !await ensureAccount(context, authController, 'participar no desafio')) {
      return;
    }
    if (context.mounted) Navigator.pushNamed(context, route, arguments: arguments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: notificationController,
            builder: (context, _) {
              final notifications = notificationController.notifications;
              final hasUnread = notificationController.unreadCount > 0;

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Row(
                    children: [
                      RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Voltar',
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Notificações', style: Theme.of(context).textTheme.headlineMedium)),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: hasUnread ? notificationController.markAllAsRead : null,
                      child: const Text('Marcar todas como lidas'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (notifications.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Text(
                        'Não tens notificações.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: AppColors.textMuted),
                      ),
                    ),
                  for (final notification in notifications) ...[
                    _NotificationTile(
                      notification: notification,
                      isRead: notificationController.isRead(notification),
                      onTap: () => _open(context, notification),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.isRead, required this.onTap});

  final AppNotification notification;
  final bool isRead;
  final VoidCallback onTap;

  static (IconData, Color) _style(NotificationType type) {
    return switch (type) {
      NotificationType.message => (Icons.chat_bubble_outline_rounded, AppColors.link),
      NotificationType.comment => (Icons.mode_comment_outlined, Color(0xFF5EEAD4)),
      NotificationType.groupReminder => (Icons.groups_rounded, Color(0xFFC4B5FD)),
      NotificationType.challenge => (Icons.emoji_events_outlined, AppColors.gold),
      NotificationType.streak => (Icons.local_fire_department_rounded, AppColors.gold),
    };
  }

  String _when(DateTime date) {
    final now = DateTime.now();
    if (DateFormatter.isSameDay(date, now)) {
      return date.hour == 0 && date.minute == 0 ? 'Hoje' : DateFormatter.time(date);
    }
    if (DateFormatter.isSameDay(date, DateTime(now.year, now.month, now.day - 1))) return 'Ontem';
    return DateFormatter.shortDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _style(notification.type);

    return Material(
      color: isRead ? AppColors.surface : const Color(0xFF1B2433),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: isRead ? AppColors.surfaceBorder : const Color(0x553A93FF)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 20, backgroundColor: color.withAlpha(41), child: Icon(icon, color: color, size: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, height: 1.35, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_when(notification.date), style: const TextStyle(fontSize: 12, color: AppColors.textSubtle)),
                  if (!isRead) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
