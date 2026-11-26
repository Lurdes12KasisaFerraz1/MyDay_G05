import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import 'round_icon_button.dart';

/// Cabeçalho dos ecrãs de código e de recuperação da palavra-passe.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RoundIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Voltar',
              onPressed: () => Navigator.maybePop(context),
            ),
            Image.asset(AppImages.logoIcon, height: 30),
          ],
        ),
        const SizedBox(height: 28),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppColors.primaryGlow,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 18),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(fontSize: 15, height: 1.45, color: AppColors.textSecondary)),
      ],
    );
  }
}

/// Mostra o código enquanto a app não envia emails e SMS reais.
class DemoCodeNotice extends StatelessWidget {
  const DemoCodeNotice({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x1FF2B33D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x66F2B33D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Modo demonstração: o código enviado é ',
                children: [
                  TextSpan(
                    text: code,
                    style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2, color: Colors.white),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
