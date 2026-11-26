import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../services/data_service.dart';
import 'auth_controller.dart';
import 'diary_controller.dart';
import 'message_controller.dart';
import 'project_controller.dart';

/// Junta numa lista o que merece a atenção do utilizador. As notificações são
/// calculadas a partir dos dados; aqui só se guarda quais já foram lidas.
class NotificationController extends ChangeNotifier {
  NotificationController(
    this._dataService,
    this._authController,
    this._diaryController,
    this._messageController,
    this._projectController,
  ) {
    // Quando os dados mudam, a lista de notificações também muda.
    for (final source in _sources) {
      source.addListener(notifyListeners);
    }
  }

  final DataService _dataService;
  final AuthController _authController;
  final DiaryController _diaryController;
  final MessageController _messageController;
  final ProjectController _projectController;
  final Set<String> _readIds = {};

  List<ChangeNotifier> get _sources => [_diaryController, _messageController, _projectController];

  List<AppNotification> get notifications {
    final me = _authController.currentUser;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = <AppNotification>[
      AppNotification(
        id: 'challenge-${today.difference(DateTime(2026)).inDays ~/ 7}',
        type: NotificationType.challenge,
        title: 'Desafio da semana',
        body: _dataService.weeklyChallenge,
        date: today.subtract(Duration(days: today.weekday - 1)),
      ),
    ];
    if (me == null || me.isGuest) return result;

    for (final conversation in _messageController.conversations) {
      if (conversation.unread == 0) continue;
      final contact = conversation.contact;
      result.add(
        AppNotification(
          id: 'message-${conversation.lastMessage.id}',
          type: NotificationType.message,
          title: '${contact.firstName} enviou-te uma mensagem',
          body: conversation.lastMessage.text,
          date: conversation.lastMessage.sentAt,
          target: contact,
        ),
      );
    }

    for (final entry in _diaryController.entries) {
      for (final (index, comment) in entry.comments.indexed) {
        if (comment.authorName == me.name) continue;
        result.add(
          AppNotification(
            id: 'comment-${entry.id}-$index',
            type: NotificationType.comment,
            title: '${comment.authorName} comentou «${entry.title}»',
            body: comment.text,
            date: comment.createdAt,
            target: entry,
          ),
        );
      }
    }

    for (final group in _projectController.groups) {
      final reminder = group.reminder;
      if (reminder == null || !reminder.isActive || !group.hasMember(me)) continue;
      result.add(
        AppNotification(
          id: 'reminder-${group.id}-${today.toIso8601String()}',
          type: NotificationType.groupReminder,
          title: '${group.name}: ${reminder.title}',
          body: reminder.schedule,
          date: today,
          target: group,
        ),
      );
    }

    final streak = _diaryController.currentStreak;
    final nextReward = _diaryController.nextReward;
    if (_diaryController.todayEntries.isEmpty && streak > 0) {
      result.add(
        AppNotification(
          id: 'streak-${today.toIso8601String()}',
          type: NotificationType.streak,
          title: 'Não percas a sequência!',
          body: 'Ainda não registaste nada hoje. Tens $streak dias seguidos.',
          date: today,
        ),
      );
    } else if (nextReward != null) {
      result.add(
        AppNotification(
          id: 'reward-${nextReward.days}-$streak',
          type: NotificationType.streak,
          title: '$streak dias seguidos 🔥',
          body: 'Faltam ${nextReward.days - streak} dias para a recompensa «${nextReward.title}».',
          date: today,
        ),
      );
    }

    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  bool isRead(AppNotification notification) => _readIds.contains(notification.id);

  int get unreadCount => notifications.where((notification) => !isRead(notification)).length;

  void markAsRead(AppNotification notification) {
    if (_readIds.add(notification.id)) notifyListeners();
  }

  void markAllAsRead() {
    _readIds.addAll(notifications.map((notification) => notification.id));
    notifyListeners();
  }

  @override
  void dispose() {
    for (final source in _sources) {
      source.removeListener(notifyListeners);
    }
    super.dispose();
  }
}
