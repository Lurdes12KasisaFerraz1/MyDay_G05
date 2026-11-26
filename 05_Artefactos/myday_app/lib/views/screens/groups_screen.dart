import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/project_controller.dart';
import '../../models/study_group.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../widgets/app_background.dart';
import '../widgets/project_card.dart';
import '../widgets/round_icon_button.dart';
import '../widgets/section_header.dart';

/// Todos os grupos de estudo: primeiro os do utilizador, depois os restantes.
class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key, required this.projectController, required this.authController});

  final ProjectController projectController;
  final AuthController authController;

  void _open(BuildContext context, StudyGroup group) {
    Navigator.pushNamed(context, AppRoutes.groupDetail, arguments: group);
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
              final groups = projectController.groups;
              final mine = [for (final group in groups) if (me != null && group.hasMember(me)) group];
              final others = [for (final group in groups) if (!mine.contains(group)) group];

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Row(
                    children: [
                      RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Voltar',
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Text('Grupos de estudo', style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SectionHeader(title: 'Os meus grupos', counter: '${mine.length}'),
                  const SizedBox(height: 12),
                  if (mine.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text('Ainda não estás em nenhum grupo.', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  for (final group in mine) ...[
                    StudyGroupCard(group: group, onTap: () => _open(context, group)),
                    const SizedBox(height: 12),
                  ],
                  if (others.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const SectionHeader(title: 'Outros grupos'),
                    const SizedBox(height: 12),
                    for (final group in others) ...[
                      StudyGroupCard(group: group, onTap: () => _open(context, group)),
                      const SizedBox(height: 12),
                    ],
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
