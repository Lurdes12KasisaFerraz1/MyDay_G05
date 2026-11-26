import 'package:flutter/foundation.dart';

import '../models/message.dart';
import '../models/user.dart';
import '../services/data_service.dart';
import '../utils/app_exception.dart';
import 'auth_controller.dart';

/// Resumo de uma conversa para a lista de mensagens.
typedef Conversation = ({User contact, Message lastMessage, int unread});

class MessageController extends ChangeNotifier {
  MessageController(this._dataService, this._authController);

  static const int maxLength = 1000;

  final DataService _dataService;
  final AuthController _authController;

  User? get _me => _authController.currentUser;

  /// Conversas do utilizador atual, da mais recente para a mais antiga.
  List<Conversation> get conversations {
    final me = _me;
    if (me == null) return const [];

    final byContact = <User, List<Message>>{};
    for (final message in _dataService.messages) {
      if (!message.involves(me)) continue;
      byContact.putIfAbsent(message.otherThan(me), () => []).add(message);
    }

    final result = [
      for (final MapEntry(key: contact, value: messages) in byContact.entries)
        (
          contact: contact,
          lastMessage: messages.reduce((a, b) => a.sentAt.isAfter(b.sentAt) ? a : b),
          unread: messages.where((m) => m.receiver == me && !m.isRead).length,
        ),
    ];
    result.sort((a, b) => b.lastMessage.sentAt.compareTo(a.lastMessage.sentAt));
    return result;
  }

  int get unreadCount => conversations.fold(0, (total, conversation) => total + conversation.unread);

  /// Pessoas a quem se pode escrever: todas as contas exceto a própria.
  List<User> get contacts {
    final me = _me;
    return _dataService.users.where((user) => user != me && !user.isAdmin).toList();
  }

  List<Message> messagesWith(User contact) {
    final me = _me;
    if (me == null) return const [];
    return _dataService.messages.where((m) => m.involves(me) && m.involves(contact)).toList()
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
  }

  /// Marca como lidas as mensagens recebidas de [contact].
  void markAsRead(User contact) {
    final me = _me;
    if (me == null) return;

    var changed = false;
    for (final message in _dataService.messages) {
      if (message.sender == contact && message.receiver == me && !message.isRead) {
        message.readAt = DateTime.now();
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void send(User contact, String text) {
    final me = _me;
    final content = text.trim();
    if (me == null || me.isGuest) {
      throw const AppException('Precisas de uma conta para enviar mensagens.', title: 'Sem conta');
    }
    if (content.isEmpty) return;
    if (content.length > maxLength) {
      throw const AppException('A mensagem pode ter no máximo $maxLength caracteres.', title: 'Mensagem demasiado longa');
    }

    _dataService.addMessage(
      Message(
        id: _dataService.nextMessageId(),
        sender: me,
        receiver: contact,
        text: content,
        sentAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
