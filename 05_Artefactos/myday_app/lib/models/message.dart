import 'user.dart';

/// Mensagem privada entre dois utilizadores (tabela mensagem).
class Message {
  Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.text,
    required this.sentAt,
    this.readAt,
  });

  final String id;
  final User sender;
  final User receiver;
  final String text;
  final DateTime sentAt;

  /// Fica null até o destinatário abrir a conversa.
  DateTime? readAt;

  bool get isRead => readAt != null;

  /// Devolve a outra pessoa da conversa, vista por [user].
  User otherThan(User user) => sender == user ? receiver : sender;

  bool involves(User user) => sender == user || receiver == user;
}
