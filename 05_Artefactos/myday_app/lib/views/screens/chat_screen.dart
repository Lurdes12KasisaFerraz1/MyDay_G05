import 'package:flutter/material.dart';

import '../../controllers/message_controller.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_exception.dart';
import '../../utils/date_formatter.dart';
import '../../utils/messages.dart';
import '../widgets/round_icon_button.dart';

/// Conversa privada com outro utilizador.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.contact, required this.messageController});

  final User contact;
  final MessageController messageController;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Marcar como lidas notifica os ouvintes, por isso espera pelo fim do build.
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.messageController.markAsRead(widget.contact));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _send() {
    try {
      widget.messageController.send(widget.contact, _textController.text);
      _textController.clear();
    } on AppException catch (error) {
      showErrorAlert(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.contact;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _ChatHeader(contact: contact),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.messageController,
                builder: (context, _) {
                  final messages = widget.messageController.messagesWith(contact);
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'Diz olá a ${contact.firstName}!',
                        style: const TextStyle(fontSize: 15, color: AppColors.textMuted),
                      ),
                    );
                  }

                  // Lista invertida: a mensagem mais recente fica sempre visível em baixo.
                  final reversed = messages.reversed.toList();
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: reversed.length,
                    itemBuilder: (context, index) {
                      final message = reversed[index];
                      final older = index + 1 < reversed.length ? reversed[index + 1] : null;
                      final startsNewDay = older == null || !DateFormatter.isSameDay(older.sentAt, message.sentAt);

                      return Column(
                        children: [
                          if (startsNewDay) _DayDivider(date: message.sentAt),
                          _MessageBubble(
                            message: message,
                            isMine: message.sender != contact,
                            showReadState: index == 0,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            _MessageInput(controller: _textController, onSend: _send),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.contact});

  final User contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          RoundIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Voltar',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          CircleAvatar(radius: 20, backgroundImage: AssetImage(contact.avatarPath)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                Text(contact.course, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final label = DateFormatter.isSameDay(date, now)
        ? 'Hoje'
        : DateFormatter.isSameDay(date, DateTime(now.year, now.month, now.day - 1))
            ? 'Ontem'
            : DateFormatter.longDate(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: AppColors.glass, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine, required this.showReadState});

  final Message message;
  final bool isMine;

  /// Só a última mensagem mostra se já foi lida, como nas apps de chat.
  final bool showReadState;

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(18);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isMine ? AppColors.primaryGradient : null,
                color: isMine ? null : AppColors.surface,
                border: isMine ? null : Border.all(color: AppColors.surfaceBorder),
                borderRadius: BorderRadius.only(
                  topLeft: radius,
                  topRight: radius,
                  bottomLeft: isMine ? radius : const Radius.circular(4),
                  bottomRight: isMine ? const Radius.circular(4) : radius,
                ),
              ),
              child: Text(message.text, style: const TextStyle(fontSize: 15, height: 1.35, color: Colors.white)),
            ),
            const SizedBox(height: 3),
            Text(
              isMine && showReadState
                  ? '${DateFormatter.time(message.sentAt)} · ${message.isRead ? 'Lida' : 'Enviada'}'
                  : DateFormatter.time(message.sentAt),
              style: const TextStyle(fontSize: 11, color: AppColors.textSubtle),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.navBar,
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSend(),
              textInputAction: TextInputAction.send,
              minLines: 1,
              maxLines: 4,
              maxLength: MessageController.maxLength,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Escreve uma mensagem…',
                hintStyle: const TextStyle(color: AppColors.textSubtle),
                counterText: '',
                filled: true,
                fillColor: AppColors.glass,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(23),
              boxShadow: AppColors.primaryGlow,
            ),
            child: IconButton(
              tooltip: 'Enviar mensagem',
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}
