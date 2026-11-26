import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../utils/app_routes.dart';
import '../widgets/app_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  static const Duration _displayTime = Duration(milliseconds: 3600);

  late final AnimationController _ringsController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_displayTime, _openWelcome);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ringsController.dispose();
    super.dispose();
  }

  void _openWelcome() {
    _timer?.cancel();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _openWelcome,
        child: AppBackground(
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                SizedBox(
                  width: 320,
                  height: 320,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      for (var ring = 0; ring < 3; ring++) _PulsingRing(animation: _ringsController, delay: ring / 3),
                      const _AnimatedLogo(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const _FadeInUp(
                  delay: Duration(milliseconds: 900),
                  child: Image(image: AssetImage(AppImages.logoWordmark), height: 34),
                ),
                const SizedBox(height: 14),
                const _FadeInUp(
                  delay: Duration(milliseconds: 1200),
                  child: Text(
                    'O teu diário de aprendizagem',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                  ),
                ),
                const Spacer(flex: 4),
                const _LoadingBar(duration: _displayTime),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Anel que cresce e desaparece, em ciclo, à volta do logótipo.
class _PulsingRing extends StatelessWidget {
  const _PulsingRing({required this.animation, required this.delay});

  final Animation<double> animation;
  final double delay;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = (animation.value + delay) % 1;
        final opacity = progress < 0.25 ? progress * 4 : 1 - (progress - 0.25) / 0.75;
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0) * 0.5,
          child: Transform.scale(scale: 0.6 + progress * 0.5, child: child),
        );
      },
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.55, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x1FFFFFFF),
          border: Border.all(color: const Color(0x59FFFFFF)),
          boxShadow: const [
            BoxShadow(color: Color(0x80000000), blurRadius: 60, offset: Offset(0, 24)),
            BoxShadow(color: Color(0x593A93FF), blurRadius: 46, spreadRadius: 6),
          ],
        ),
        alignment: Alignment.center,
        child: Image.asset(AppImages.logoIcon, width: 118),
      ),
    );
  }
}

class _FadeInUp extends StatelessWidget {
  const _FadeInUp({required this.delay, required this.child});

  final Duration delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const animationTime = Duration(milliseconds: 700);
    final total = delay + animationTime;
    final start = delay.inMilliseconds / total.inMilliseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: Curves.easeOut),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, 16 * (1 - value)), child: child),
      ),
      child: child,
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.duration});

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        width: 48,
        height: 4,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: duration,
          builder: (context, value, _) => LinearProgressIndicator(
            value: value,
            backgroundColor: const Color(0x38FFFFFF),
            color: AppColors.primaryLight,
          ),
        ),
      ),
    );
  }
}
