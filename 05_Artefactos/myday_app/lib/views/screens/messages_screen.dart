import 'package:flutter/material.dart';

import '../../controllers/message_controller.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/date_formatter.dart';
import '../widgets/app_background.dart';
import '../widgets/round_icon_button.dart';

/// Lista das conversas do utilizador.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key, required this.messageController});

  final MessageController messageController;

  void _openChat(BuildContext context, User contact) {
    Navigator.pushNamed(context, AppRoutes.chat, arguments: contact);
  }

  Future<void> _newMessage(BuildContext context) async {
    final contact = await showModalBottomSheet<User>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Nova mensagem', style: Theme.of(sheetContext).textTheme.titleLarge),
            ),
            for (final user in messageController.contacts)
              ListTile(
                leading: CircleAvatar(backgroundImage: AssetImage(user.avatarPath)),
                title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                subtitle: Text(user.course, style: Theme.of(sheetContext).textTheme.bodySmall),
                onTap: () => Navigator.pop(sheetContext, user),
              ),
          ],
        ),
      ),
    );
    if (contact != null && context.mounted) _openChat(context, contact);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova mensagem',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _newMessage(context),
        child: const Icon(Icons.edit_outlined),
      ),
      body: AppBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: messageController,
            builder: (context, _) {
              final conversations = messageController.conversations;

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                children: [
                  Row(
                    children: [
                      RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Voltar',
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Text('Mensagens', style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (conversations.isEmpty)
                    const _EmptyMessages()
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (final conversation in conversations)
                            _ConversationTile(
                              conversation: conversation,
                              onTap: () => _openChat(context, conversation.contact),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.onTap});

  final Conversation conversation;
  final VoidCallback onTap;

  String _when(DateTime date) {
    final now = DateTime.now();
    if (DateFormatter.isSameDay(date, now)) return DateFormatter.time(date);
    if (DateFormatter.isSameDay(date, DateTime(now.year, now.month, now.day - 1))) return 'Ontem';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final (:contact, :lastMessage, :unread) = conversation;
    final isMine = lastMessage.sender != contact;
    final hasUnread = unread > 0;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: CircleAvatar(radius: 24, backgroundImage: AssetImage(contact.avatarPath)),
      title: Text(
        contact.name,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
      ),
      subtitle: Text(
        isMine ? 'Tu: ${lastMessage.text}' : lastMessage.text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
          color: hasUnread ? Colors.white : AppColors.textMuted,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _when(lastMessage.sentAt),
            style: TextStyle(fontSize: 12, color: hasUnread ? AppColors.link : AppColors.textSubtle),
          ),
          const SizedBox(height: 6),
          if (hasUnread)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(999)),
              child: Text(
                '$unread',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.textSubtle),
          SizedBox(height: 12),
          Text(
            'Ainda não tens conversas.\nCarrega no lápis para escrever a alguém.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
