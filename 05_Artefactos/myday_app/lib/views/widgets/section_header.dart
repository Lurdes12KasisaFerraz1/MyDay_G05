import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

/// Título de secção com um contador ou uma ação à direita.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.counter, this.actionLabel, this.onAction});

  final String title;
  final String? counter;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        if (counter != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.glass, borderRadius: BorderRadius.circular(999)),
            child: Text(
              counter!,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.link),
            ),
          ),
      ],
    );
  }
}
