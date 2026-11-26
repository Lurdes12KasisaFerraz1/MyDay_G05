import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/diary_controller.dart';
import '../../controllers/message_controller.dart';
import '../../controllers/project_controller.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/text_search.dart';
import '../widgets/app_background.dart';
import '../widgets/entry_card.dart';
import '../widgets/guest_prompt.dart';
import '../widgets/project_card.dart';
import '../widgets/round_icon_button.dart';
import '../widgets/section_header.dart';

/// Pesquisa em registos, projetos, grupos e pessoas.
class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.diaryController,
    required this.projectController,
    required this.messageController,
    required this.authController,
  });

  final DiaryController diaryController;
  final ProjectController projectController;
  final MessageController messageController;
  final AuthController authController;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _queryController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _openChat(User contact) async {
    final hasAccount = await ensureAccount(context, widget.authController, 'enviar mensagens');
    if (!hasAccount || !mounted) return;
    Navigator.pushNamed(context, AppRoutes.chat, arguments: contact);
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _query.trim().isNotEmpty;
    final entries = hasQuery ? widget.diaryController.search(_query) : const [];
    final projects = hasQuery ? widget.projectController.searchProjects(_query) : const [];
    final groups = hasQuery ? widget.projectController.searchGroups(_query) : const [];
    final people = hasQuery
        ? widget.messageController.contacts.where((user) => TextSearch.matches(_query, [user.name, user.course])).toList()
        : const <User>[];
    final hasResults = entries.isNotEmpty || projects.isNotEmpty || groups.isNotEmpty || people.isNotEmpty;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    RoundIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Voltar',
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _queryController,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        onChanged: (value) => setState(() => _query = value),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Registos, projetos, grupos, pessoas…',
                          hintStyle: const TextStyle(color: AppColors.textSubtle),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSubtle),
                          suffixIcon: hasQuery
                              ? IconButton(
                                  tooltip: 'Limpar',
                                  icon: const Icon(Icons.close_rounded, color: AppColors.textSubtle),
                                  onPressed: () => setState(() {
                                    _queryController.clear();
                                    _query = '';
                                  }),
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.glass,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  children: [
                    if (!hasQuery)
                      const _SearchHint(text: 'Escreve para procurar. Por exemplo: derivadas, SQL ou Ana.')
                    else if (!hasResults)
                      _SearchHint(text: 'Nada encontrado para «${_query.trim()}».'),
                    if (entries.isNotEmpty) ...[
                      SectionHeader(title: 'Registos', counter: '${entries.length}'),
                      const SizedBox(height: 10),
                      for (final entry in entries) ...[
                        EntryCard(
                          entry: entry,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.entryDetail, arguments: entry),
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 10),
                    ],
                    if (projects.isNotEmpty) ...[
                      SectionHeader(title: 'Projetos', counter: '${projects.length}'),
                      const SizedBox(height: 10),
                      for (final project in projects)
                        _ResultTile(
                          image: AssetImage(project.coverImage),
                          title: project.name,
                          subtitle: '${project.subject.label} · ${project.visibility.label}',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.projectDetail, arguments: project),
                        ),
                      const SizedBox(height: 10),
                    ],
                    if (groups.isNotEmpty) ...[
                      SectionHeader(title: 'Grupos', counter: '${groups.length}'),
                      const SizedBox(height: 10),
                      for (final group in groups) ...[
                        StudyGroupCard(
                          group: group,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.groupDetail, arguments: group),
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 10),
                    ],
                    if (people.isNotEmpty) ...[
                      SectionHeader(title: 'Pessoas', counter: '${people.length}'),
                      const SizedBox(height: 10),
                      for (final user in people)
                        _ResultTile(
                          image: AssetImage(user.avatarPath),
                          title: user.name,
                          subtitle: user.course,
                          trailingIcon: Icons.chat_bubble_outline_rounded,
                          onTap: () => _openChat(user),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15, height: 1.4, color: AppColors.textMuted),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingIcon = Icons.chevron_right_rounded,
  });

  final ImageProvider image;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          leading: CircleAvatar(radius: 22, backgroundImage: image),
          title: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          trailing: Icon(trailingIcon, color: AppColors.textSubtle),
        ),
      ),
    );
  }
}
