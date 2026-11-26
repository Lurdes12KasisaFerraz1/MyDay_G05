import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/diary_controller.dart';
import '../../models/project.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../widgets/entry_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/guest_prompt.dart';
import '../widgets/round_icon_button.dart';
import '../widgets/section_header.dart';
import '../widgets/tags.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({
    super.key,
    required this.project,
    required this.diaryController,
    required this.authController,
  });

  final Project project;
  final DiaryController diaryController;
  final AuthController authController;

  Future<void> _newEntry(BuildContext context) async {
    if (!await ensureAccount(context, authController, 'guardar registos')) return;
    if (context.mounted) {
      Navigator.pushNamed(context, AppRoutes.newEntry, arguments: project.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListenableBuilder(
        listenable: diaryController,
        builder: (context, _) {
          final entries = diaryController.entriesForProject(project.name);
          final subjects = {for (final entry in entries) entry.subject};

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Cover(project: project)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                sliver: SliverList.list(
                  children: [
                    Text(project.description, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    _StatsRow(
                      stats: [
                        ('${entries.length}', 'Registos'),
                        ('${entries.where((entry) => entry.hasCoordinates).length}', 'Com local'),
                        (diaryController.lastActivityFor(project.name), 'Última atividade'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [for (final subject in {project.subject, ...subjects}) SubjectChip(subject: subject)],
                    ),
                    const SizedBox(height: 18),
                    GradientButton(
                      label: 'Novo registo neste projeto',
                      icon: Icons.add_rounded,
                      onPressed: () => _newEntry(context),
                    ),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Registos recentes',
                      counter: entries.length == 1 ? '1 registo' : '${entries.length} registos',
                    ),
                    const SizedBox(height: 12),
                    if (entries.isEmpty)
                      const Text('Ainda não há registos neste projeto.', style: TextStyle(color: AppColors.textMuted)),
                    for (final entry in entries) ...[
                      EntryCard(
                        entry: entry,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.entryDetail, arguments: entry),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(project.coverImage, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x730B0B0E), Colors.transparent, Color(0xE60B0B0E), AppColors.background],
                stops: [0, 0.35, 0.82, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Voltar',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  VisibilityBadge(visibility: project.visibility, onImage: true),
                  const SizedBox(height: 8),
                  Text(project.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final List<(String value, String label)> stats;

  @override
  Widget build(BuildContext context) {
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
