import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../utils/app_routes.dart';
import '../widgets/gradient_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppImages.welcome, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x4D0B0B0E), Color(0x330B0B0E), Color(0xC70B0B0E), Color(0xF70B0B0E), AppColors.background],
                stops: [0, 0.3, 0.56, 0.78, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Logo(),
                  const Spacer(),
                  const _Headline(),
                  const SizedBox(height: 16),
                  const Text(
                    'Regista o que aprendes com fotos, áudio e notas, organiza por projeto '
                    'e partilha com a tua turma.',
                    style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xD1FFFFFF)),
                  ),
                  const SizedBox(height: 16),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FeatureChip(icon: Icons.photo_camera_outlined, label: 'Fotos e áudio'),
                      _FeatureChip(icon: Icons.calendar_today_outlined, label: 'Calendário'),
                      _FeatureChip(icon: Icons.groups_outlined, label: 'Partilha com a turma'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: 'Começar',
                    showArrow: true,
                    height: 58,
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0x1FFFFFFF),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0x4DFFFFFF)),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Já tenho conta · Entrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(AppImages.logoIcon, height: 40),
        const SizedBox(width: 10),
        Image.asset(AppImages.logoWordmark, height: 18, semanticLabel: 'MyDay'),
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      const TextSpan(
        children: [
          TextSpan(text: 'O teu dia de '),
          TextSpan(text: 'estudo', style: TextStyle(color: AppColors.gold)),
          TextSpan(text: ', sempre guardado.'),
        ],
      ),
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 36, height: 1.12, letterSpacing: -1),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x47FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}
