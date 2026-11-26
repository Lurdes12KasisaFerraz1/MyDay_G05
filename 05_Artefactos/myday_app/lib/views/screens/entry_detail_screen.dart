import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/diary_controller.dart';
import '../../models/comment.dart';
import '../../models/entry.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/date_formatter.dart';
import '../../utils/messages.dart';
import '../widgets/guest_prompt.dart';
import '../widgets/round_icon_button.dart';
import '../widgets/tags.dart';

class EntryDetailScreen extends StatefulWidget {
  const EntryDetailScreen({
    super.key,
    required this.entry,
    required this.diaryController,
    required this.authController,
  });

  final Entry entry;
  final DiaryController diaryController;
  final AuthController authController;

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  static const int _projectsTab = 1;

  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final author = widget.authController.currentUser;
    if (author == null || _commentController.text.trim().isEmpty) return;
    if (!await ensureAccount(context, widget.authController, 'comentar')) return;
    if (!mounted) return;

    widget.diaryController.addComment(widget.entry, author, _commentController.text);
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  void _openProjects() {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false, arguments: _projectsTab);
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListenableBuilder(
        listenable: widget.diaryController,
        builder: (context, _) => Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _HeroImage(imagePath: entry.imagePath)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    sliver: SliverList.list(
                      children: [
                        _EntryInfo(entry: entry, onProjectTap: _openProjects),
                        const SizedBox(height: 14),
                        _ActionsBar(
                          entry: entry,
                          onFavorite: () async {
                            if (await ensureAccount(context, widget.authController, 'guardar favoritos')) {
                              widget.diaryController.toggleFavorite(entry);
                            }
                          },
                          onExport: () => showNotAvailable(context, 'A exportação em PDF'),
                        ),
                        const SizedBox(height: 16),
                        Text('Comentários', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        if (entry.comments.isEmpty)
                          const Text('Ainda não há comentários.', style: TextStyle(color: AppColors.textMuted)),
                        for (final comment in entry.comments) _CommentTile(comment: comment),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _CommentInput(controller: _commentController, onSend: _sendComment),
          ],
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imagePath != null)
            Image.asset(imagePath!, fit: BoxFit.cover)
          else
            const ColoredBox(color: AppColors.surface),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x730B0B0E), Colors.transparent, Color(0xCC0B0B0E), AppColors.background],
                stops: [0, 0.38, 0.82, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.topLeft,
                child: RoundIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Voltar',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryInfo extends StatelessWidget {
  const _EntryInfo({required this.entry, required this.onProjectTap});

  final Entry entry;
  final VoidCallback onProjectTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SubjectChip(subject: entry.subject),
            const SizedBox(width: 8),
            ActionChip(
              label: Text(entry.project),
              onPressed: onProjectTap,
              backgroundColor: AppColors.glass,
              side: BorderSide.none,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              visualDensity: VisualDensity.compact,
            ),
            const Spacer(),
            VisibilityBadge(visibility: entry.visibility),
          ],
        ),
        const SizedBox(height: 10),
        Text(entry.title, style: textTheme.headlineMedium?.copyWith(fontSize: 26)),
        const SizedBox(height: 4),
        Text(DateFormatter.shortDateTime(entry.createdAt), style: textTheme.bodySmall),
        if (entry.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(entry.text, style: textTheme.bodyLarge),
        ],
        if (entry.location != null) ...[
          const SizedBox(height: 14),
          _LocationRow(location: entry.location!),
        ],
        if (entry.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final tag in entry.tags)
                Text('#$tag', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.link)),
            ],
          ),
        ],
      ],
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.place_outlined, size: 20, color: AppColors.link),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              location,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => showNotAvailable(context, 'A vista de mapa'),
            child: const Text('Ver no mapa', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.link)),
          ),
        ],
      ),
    );
  }
}

class _ActionsBar extends StatelessWidget {
  const _ActionsBar({required this.entry, required this.onFavorite, required this.onExport});

  final Entry entry;
  final VoidCallback onFavorite;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: onFavorite,
              icon: Icon(
                entry.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: entry.isFavorite ? AppColors.favorite : AppColors.textSecondary,
              ),
              label: Text(entry.isFavorite ? 'Favorito' : 'Favoritar'),
              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: TextButton.icon(
              onPressed: null,
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: Text('${entry.comments.length}'),
              style: TextButton.styleFrom(disabledForegroundColor: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: TextButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('PDF'),
              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 18, backgroundImage: AssetImage(comment.authorAvatar)),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  topLeft: Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${comment.authorName} · ${DateFormatter.time(comment.createdAt)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 3),
                  Text(comment.text, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  const _CommentInput({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBar,
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onSend(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Escreve um comentário…',
                    hintStyle: const TextStyle(color: AppColors.textSubtle),
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
                  tooltip: 'Enviar comentário',
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: onSend,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
