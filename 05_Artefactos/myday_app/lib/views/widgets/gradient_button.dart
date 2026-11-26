import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

/// Botão principal da aplicação: gradiente azul com brilho.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.showArrow = false,
    this.icon,
    this.height = 56,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool showArrow;
  final IconData? icon;
  final double height;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: AppColors.primaryGlow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(height / 2),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Stack(
              alignment: Alignment.center,
              children: [
                content,
                if (showArrow)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0x33FFFFFF),
                      child: Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
