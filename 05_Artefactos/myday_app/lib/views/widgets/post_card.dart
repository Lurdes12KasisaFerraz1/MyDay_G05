import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../utils/app_colors.dart';
import 'tags.dart';

/// Publicação de um colega na Comunidade.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onFavorite,
    required this.onComments,
  });

  final Post post;
  final VoidCallback onFavorite;
  final VoidCallback onComments;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                CircleAvatar(radius: 20, backgroundImage: AssetImage(post.authorAvatar)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      Text('${post.project} · ${post.timeAgo}', style: textTheme.bodySmall),
                    ],
                  ),
                ),
                VisibilityBadge(visibility: post.visibility),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(post.text, style: textTheme.bodyMedium),
              ],
            ),
          ),
          Image.asset(post.imagePath, height: 170, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: onComments,
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 19),
                  label: Text('${post.commentsCount}'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                ),
                TextButton.icon(
                  onPressed: onFavorite,
                  icon: Icon(
                    post.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 19,
                    color: post.isFavorite ? AppColors.favorite : null,
                  ),
                  label: Text(post.isFavorite ? 'Favorito' : 'Favoritar'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
