import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

/// Fundo escuro com gradiente e dois brilhos suaves, comum a todos os ecrãs.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Stack(
        children: [
          const Positioned(
            top: 40,
            right: -160,
            child: _Glow(color: Color(0x243A93FF), size: 420),
          ),
          const Positioned(
            top: -120,
            left: -150,
            child: _Glow(color: Color(0x12F2B33D), size: 400),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}
