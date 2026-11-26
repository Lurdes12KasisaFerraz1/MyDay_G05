import 'package:flutter/material.dart';

import '../../models/entry.dart';
import '../../models/enums.dart';
import '../../utils/app_colors.dart';
import '../../utils/date_formatter.dart';
import 'tags.dart';

/// Cartão de um registo na lista do Diário.
class EntryCard extends StatelessWidget {
  const EntryCard({super.key, required this.entry, required this.onTap});

  final Entry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumbnail(imagePath: entry.imagePath),
              const SizedBox(width: 14),
              Expanded(child: _EntrySummary(entry: entry)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 88,
        height: 100,
        child: imagePath == null
            ? const ColoredBox(
                color: AppColors.glass,
                child: Icon(Icons.edit_note_rounded, color: AppColors.textSubtle, size: 32),
              )
            : Image.asset(imagePath!, fit: BoxFit.cover),
      ),
    );
  }
}

class _EntrySummary extends StatelessWidget {
  const _EntrySummary({required this.entry});

  final Entry entry;

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
            Text(DateFormatter.time(entry.createdAt), style: textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        Text(entry.title, style: textTheme.titleMedium),
        if (entry.text.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(entry.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: textTheme.bodyMedium),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _EntryDetail(entry: entry)),
            VisibilityBadge(visibility: entry.visibility),
          ],
        ),
      ],
    );
  }
}

/// Mostra o local ou o anexo do registo, com um ícone na cor do tipo.
class _EntryDetail extends StatelessWidget {
  const _EntryDetail({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (entry.mediaType) {
      AttachmentType.audio => (Icons.mic_none_rounded, AppColors.gold, entry.mediaLabel),
      AttachmentType.video => (Icons.videocam_outlined, const Color(0xFFF472B6), entry.mediaLabel),
      _ => (Icons.place_outlined, AppColors.link, entry.location),
    };

    if (label == null) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
