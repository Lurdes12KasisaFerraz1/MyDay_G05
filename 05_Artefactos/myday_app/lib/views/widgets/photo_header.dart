import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

/// Fotografia de topo com a base curva, usada no Entrar e no Criar conta.
class PhotoHeader extends StatelessWidget {
  const PhotoHeader({
    super.key,
    required this.imagePath,
    required this.height,
    required this.child,
    this.alignment = Alignment.center,
  });

  final String imagePath;
  final double height;
  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Color(0x73000000), blurRadius: 40, offset: Offset(0, 16))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(imagePath, fit: BoxFit.cover, alignment: alignment),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x6B0B0B0E), Color(0x1A0B0B0E), Color(0x8C0B0B0E), Color(0xD90B0B0E)],
                stops: [0, 0.34, 0.68, 1],
              ),
            ),
          ),
          SafeArea(bottom: false, child: child),
        ],
      ),
    );
  }
}

/// Texto de ligação no fundo dos formulários ("Já tens conta? Entrar").
class FooterLink extends StatelessWidget {
  const FooterLink({super.key, required this.text, required this.action, required this.onTap});

  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.link),
          ),
        ),
      ],
    );
  }
}
