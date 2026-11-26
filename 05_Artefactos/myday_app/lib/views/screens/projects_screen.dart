import 'package:flutter/material.dart';

import '../../controllers/project_controller.dart';
import '../../models/enums.dart';
import '../../utils/app_colors.dart';
import '../../utils/messages.dart';
import '../widgets/choice_tabs.dart';
import '../widgets/project_card.dart';
import '../widgets/round_icon_button.dart';
import '../widgets/section_header.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key, required this.projectController, required this.onBack});

  final ProjectController projectController;
  final VoidCallback onBack;

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
      listenable: projectController,
      builder: (context, _) {
        final projects = projectController.projects;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                RoundIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Voltar ao Diário', onPressed: onBack),
                const SizedBox(width: 12),
                Expanded(child: Text('Projetos', style: Theme.of(context).textTheme.headlineMedium)),
                FilledButton.icon(
                  onPressed: () => showNotAvailable(context, 'A criação de projetos'),
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
                      onTap: () => showNotAvailable(context, 'O detalhe do projeto'),
                    ),
                ],
              ),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'Grupos de estudo',
              actionLabel: 'Ver todos',
              onAction: () => showNotAvailable(context, 'A lista de grupos'),
            ),
            const SizedBox(height: 8),
            for (final group in projectController.groups)
              StudyGroupCard(
                group: group,
                onTap: () => showNotAvailable(context, 'O detalhe do grupo'),
              ),
          ],
        );
      },
    );
  }
}
