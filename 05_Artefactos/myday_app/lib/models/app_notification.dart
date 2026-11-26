enum NotificationType { message, comment, groupReminder, challenge, streak }

/// Notificação mostrada no ecrã de notificações.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.date,
    this.target,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime date;

  /// O que abre ao tocar: o contacto, o registo ou o grupo.
  final Object? target;
}
