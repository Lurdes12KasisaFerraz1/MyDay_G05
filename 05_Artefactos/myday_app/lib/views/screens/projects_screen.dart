import 'package:flutter/material.dart';

import '../../controllers/diary_controller.dart';
import '../../controllers/project_controller.dart';
import '../../models/enums.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../utils/app_routes.dart';
import '../widgets/choice_tabs.dart';
import '../widgets/project_card.dart';
import '../widgets/round_icon_button.dart';
import '../widgets/section_header.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({
    super.key,
    required this.projectController,
    required this.diaryController,
    required this.onBack,
    required this.onNewProject,
  });

  final ProjectController projectController;

  /// Usado para contar os registos de cada projeto.
  final DiaryController diaryController;
  final VoidCallback onBack;
  final VoidCallback onNewProject;

  static const List<EntryVisibility?> _filters = [
    null,
    EntryVisibility.private,
    EntryVisibility.friends,
    EntryVisibility.public,
  ];

  static String _filterLabel(EntryVisibility? visibility) {
    return switch (visibility) {
      null => 'Todos',
      EntryVisibility.private => 'Privados',
      EntryVisibility.friends => 'Só amigos',
      EntryVisibility.public => 'Públicos',
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([projectController, diaryController]),
      builder: (context, _) {
        final projects = projectController.projects;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                RoundIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Voltar ao Diário', onPressed: onBack),
                const SizedBox(width: 12),
                Image.asset(AppImages.logoIcon, height: 30),
                const SizedBox(width: 10),
                Expanded(child: Text('Projetos', style: Theme.of(context).textTheme.headlineMedium)),
                FilledButton.icon(
                  onPressed: onNewProject,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Novo'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.glass,
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.glassBorder),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ChoiceTabs<EntryVisibility?>(
              options: _filters,
              selected: projectController.filter,
              labelOf: _filterLabel,
              onSelected: projectController.setFilter,
            ),
            const SizedBox(height: 16),
            if (projects.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Não há projetos com este filtro.', style: TextStyle(color: AppColors.textMuted)),
              )
            else
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final project in projects)
                    ProjectCard(
                      project: project,
                      entriesCount: diaryController.entriesForProject(project.name).length,
                      lastActivity: diaryController.lastActivityFor(project.name),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.projectDetail, arguments: project),
                    ),
                ],
              ),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'Grupos de estudo',
              actionLabel: 'Ver todos',
              onAction: () => Navigator.pushNamed(context, AppRoutes.groups),
            ),
            const SizedBox(height: 8),
            for (final group in projectController.groups.take(2)) ...[
              StudyGroupCard(
                group: group,
                onTap: () => Navigator.pushNamed(context, AppRoutes.groupDetail, arguments: group),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}
