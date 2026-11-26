import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

/// Botão redondo de ícone (voltar, notificações, mensagens...).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.showBadge = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: AppColors.glass,
          shape: const CircleBorder(side: BorderSide(color: AppColors.glassBorder)),
          child: IconButton(
            tooltip: tooltip,
            icon: Icon(icon, size: 21, color: AppColors.textPrimary),
            onPressed: onPressed,
          ),
        ),
        if (showBadge)
          Positioned(
            top: 10,
            right: 11,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: AppColors.errorBorder,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
