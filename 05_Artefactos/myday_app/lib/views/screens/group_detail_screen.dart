import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/project_controller.dart';
import '../../models/enums.dart';
import '../../models/study_group.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_exception.dart';
import '../../utils/app_routes.dart';
import '../../utils/date_formatter.dart';
import '../../utils/messages.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';
import '../widgets/guest_prompt.dart';
import '../widgets/round_icon_button.dart';
import '../widgets/section_header.dart';

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({
    super.key,
    required this.group,
    required this.projectController,
    required this.authController,
  });

  final StudyGroup group;
  final ProjectController projectController;
  final AuthController authController;

  Future<void> _join(BuildContext context) async {
    final user = authController.currentUser;
    if (user == null || !await ensureAccount(context, authController, 'entrar num grupo')) return;
    if (!context.mounted) return;

    try {
      projectController.joinGroup(group, user);
      showMessage(context, 'Entraste no grupo ${group.name}.');
    } on AppException catch (error) {
      showErrorAlert(context, error);
    }
  }

  Future<void> _leave(BuildContext context) async {
    final user = authController.currentUser;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sair do grupo?'),
        content: Text('Deixas de ver os registos partilhados em ${group.name}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sair', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      projectController.leaveGroup(group, user);
    } on AppException catch (error) {
      showErrorAlert(context, error);
    }
  }

  Future<void> _openChat(BuildContext context, User contact) async {
    final hasAccount = await ensureAccount(context, authController, 'enviar mensagens');
    if (!hasAccount || !context.mounted) return;
    Navigator.pushNamed(context, AppRoutes.chat, arguments: contact);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: projectController,
            builder: (context, _) {
              final me = authController.currentUser;
              final isMember = me != null && group.hasMember(me);
              final isOwner = me != null && group.owner == me;

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RoundIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Voltar',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _GroupHeader(group: group),
                  const SizedBox(height: 16),
                  Text(group.description, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  _GroupStats(group: group),
                  const SizedBox(height: 18),
                  if (!isMember)
                    GradientButton(
                      label: 'Entrar no grupo',
                      icon: Icons.group_add_rounded,
                      onPressed: () => _join(context),
                    )
                  else if (!isOwner)
                    OutlinedButton.icon(
                      onPressed: () => _leave(context),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Sair do grupo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.errorBorder),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  if (group.reminder != null) ...[
                    const SizedBox(height: 22),
                    const SectionHeader(title: 'Lembrete do grupo'),
                    const SizedBox(height: 12),
                    _ReminderCard(
                      reminder: group.reminder!,
                      canEdit: isOwner,
                      onToggle: () => projectController.toggleReminder(group),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SectionHeader(
                    title: 'Membros',
                    counter: group.membersCount == 1 ? '1 membro' : '${group.membersCount} membros',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (final member in group.members)
                          _MemberTile(
                            member: member,
                            isMe: member.user == me,
                            onMessage: () => _openChat(context, member.user),
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

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});

  final StudyGroup group;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.primaryGlow,
          ),
          child: const Icon(Icons.groups_rounded, color: Colors.white, size: 34),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.name, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 2),
              Text('Criado por ${group.owner.name}', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _GroupStats extends StatelessWidget {
  const _GroupStats({required this.group});

  final StudyGroup group;

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('${group.membersCount}', 'Membros'),
      ('${group.sharedEntries}', 'Registos'),
      (DateFormatter.shortDate(group.createdAt), 'Criado em'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          for (final (value, label) in stats)
            Expanded(
              child: Column(
                children: [
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder, required this.canEdit, required this.onToggle});

  final GroupReminder reminder;

  /// Só o dono do grupo liga e desliga o lembrete.
  final bool canEdit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0x33F2B33D),
            child: Icon(
              reminder.isActive ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                Text(reminder.schedule, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: reminder.isActive,
            activeTrackColor: AppColors.primary,
            onChanged: canEdit ? (_) => onToggle() : null,
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.isMe, required this.onMessage});

  final GroupMember member;
  final bool isMe;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final isOwner = member.role == GroupRole.owner;

    return ListTile(
      leading: CircleAvatar(backgroundImage: AssetImage(member.user.avatarPath)),
      title: Text(
        isMe ? '${member.user.name} (tu)' : member.user.name,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      subtitle: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isOwner ? AppColors.gold : AppColors.glass,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              member.role.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isOwner ? const Color(0xFF3D2800) : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('desde ${DateFormatter.shortDate(member.joinedAt)}', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      trailing: isMe
          ? null
          : IconButton(
              tooltip: 'Enviar mensagem',
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.link),
              onPressed: onMessage,
            ),
    );
  }
}
