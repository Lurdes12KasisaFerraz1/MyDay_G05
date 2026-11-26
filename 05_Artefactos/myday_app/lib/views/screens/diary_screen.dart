import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/diary_controller.dart';
import '../../models/entry.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/date_formatter.dart';
import '../../utils/messages.dart';
import '../widgets/entry_card.dart';
import '../widgets/round_icon_button.dart';
import '../widgets/section_header.dart';
import '../widgets/streak_card.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key, required this.diaryController, required this.authController});

  final DiaryController diaryController;
  final AuthController authController;

  void _openEntry(BuildContext context, Entry entry) {
    Navigator.pushNamed(context, AppRoutes.entryDetail, arguments: entry);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: diaryController,
      builder: (context, _) {
        final user = authController.currentUser;
        final today = diaryController.todayEntries;
        final yesterday = diaryController.yesterdayEntries;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _Header(
              firstName: user?.firstName ?? 'estudante',
              avatarPath: user?.avatarPath,
            ),
            const SizedBox(height: 18),
            StreakCard(
              streakDays: user?.streakDays ?? 0,
              entriesThisWeek: diaryController.entriesThisWeek,
              weekActivity: diaryController.weekActivity,
            ),
            const SizedBox(height: 16),
            const _ViewSelector(),
            const SizedBox(height: 20),
            SectionHeader(title: 'Hoje', counter: _countLabel(today.length)),
            const SizedBox(height: 12),
            if (today.isEmpty)
              const _EmptyDay()
            else
              for (final entry in today) ...[
                EntryCard(entry: entry, onTap: () => _openEntry(context, entry)),
                const SizedBox(height: 12),
              ],
            if (yesterday.isNotEmpty) ...[
              const SizedBox(height: 8),
              SectionHeader(title: 'Ontem', counter: _countLabel(yesterday.length)),
              const SizedBox(height: 12),
              for (final entry in yesterday) ...[
                EntryCard(entry: entry, onTap: () => _openEntry(context, entry)),
                const SizedBox(height: 12),
              ],
            ],
          ],
        );
      },
    );
  }

  String _countLabel(int count) => count == 1 ? '1 registo' : '$count registos';
}

class _Header extends StatelessWidget {
  const _Header({required this.firstName, required this.avatarPath});

  final String firstName;
  final String? avatarPath;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.glass,
          backgroundImage: avatarPath == null ? null : AssetImage(avatarPath!),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormatter.longDate(DateTime.now()),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
              ),
              Text(
                'Olá, $firstName',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ],
          ),
        ),
        RoundIconButton(
          icon: Icons.search_rounded,
          tooltip: 'Pesquisar',
          onPressed: () => showNotAvailable(context, 'A pesquisa'),
        ),
        const SizedBox(width: 8),
        RoundIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notificações',
          showBadge: true,
          onPressed: () => showNotAvailable(context, 'O ecrã de notificações'),
        ),
      ],
    );
  }
}

/// Escolha entre lista, mapa e calendário. Nesta versão só a lista existe.
class _ViewSelector extends StatelessWidget {
  const _ViewSelector();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const _ViewOption(icon: Icons.view_list_rounded, label: 'Lista', isSelected: true),
          _ViewOption(
            icon: Icons.map_outlined,
            label: 'Mapa',
            onTap: () => showNotAvailable(context, 'A vista de mapa'),
          ),
          _ViewOption(
            icon: Icons.calendar_today_outlined,
            label: 'Calendário',
            onTap: () => showNotAvailable(context, 'A vista de calendário'),
          ),
        ],
      ),
    );
  }
}

class _ViewOption extends StatelessWidget {
  const _ViewOption({required this.icon, required this.label, this.isSelected = false, this.onTap});

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.background : AppColors.textMuted;

    return Expanded(
      child: Material(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: const Text(
        'Ainda não registaste nada hoje. Carrega no + para guardar o que aprendeste.',
        style: TextStyle(fontSize: 14, height: 1.45, color: AppColors.textSecondary),
      ),
    );
  }
}
