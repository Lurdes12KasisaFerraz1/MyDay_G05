import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../utils/app_colors.dart';

/// Etiqueta colorida com o nome da disciplina.
class SubjectChip extends StatelessWidget {
  const SubjectChip({super.key, required this.subject});

  final Subject subject;

  static const Map<Subject, (Color, Color)> _colors = {
    Subject.mathematics: (Color(0x294DA3FF), Color(0xFF7DB8FF)),
    Subject.databases: (Color(0x2EA78BFA), Color(0xFFC4B5FD)),
    Subject.mobile: (Color(0x292DD4BF), Color(0xFF5EEAD4)),
    Subject.chemistry: (Color(0x29F2B33D), Color(0xFFF2C86B)),
  };

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _colors[subject]!;
    return _Pill(label: subject.label, background: background, foreground: foreground);
  }
}

/// Indica quem pode ver um registo, projeto ou publicação.
class VisibilityBadge extends StatelessWidget {
  const VisibilityBadge({super.key, required this.visibility, this.onImage = false});

  final EntryVisibility visibility;

  /// Quando a etiqueta fica por cima de uma fotografia precisa de fundo opaco.
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final icon = switch (visibility) {
      EntryVisibility.private => Icons.lock_outline_rounded,
      EntryVisibility.friends => Icons.people_outline_rounded,
      EntryVisibility.public => Icons.public_rounded,
    };
    final isFriends = visibility == EntryVisibility.friends;
    final isPublic = visibility == EntryVisibility.public;

    final Color background;
    if (isPublic && onImage) {
      background = AppColors.primary;
    } else if (onImage) {
      background = const Color(0xB80B0B0E);
    } else {
      background = isFriends ? const Color(0x1F5EEAD4) : AppColors.glass;
    }
    final foreground = isFriends && !onImage ? const Color(0xFF5EEAD4) : AppColors.textSecondary;

    return _Pill(
      label: visibility.label,
      icon: icon,
      background: background,
      foreground: onImage ? Colors.white : foreground,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: foreground),
          ),
        ],
      ),
    );
  }
}
