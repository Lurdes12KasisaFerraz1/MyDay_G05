import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0B0B0E);
  static const Color backgroundLight = Color(0xFF17181D);
  static const Color surface = Color(0xFF17181D);
  static const Color surfaceBorder = Color(0x12FFFFFF);
  static const Color glass = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x24FFFFFF);
  static const Color navBar = Color(0xDB0B0B0E);

  static const Color primary = Color(0xFF0B66D0);
  static const Color primaryLight = Color(0xFF3A93FF);
  static const Color primaryDark = Color(0xFF0A47B5);
  static const Color link = Color(0xFF8CC2FF);
  static const Color gold = Color(0xFFF2B33D);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFC4C6CE);
  static const Color textMuted = Color(0xFFA1A4AE);
  static const Color textSubtle = Color(0xFF8E919B);

  static const Color error = Color(0xFFFF8A8E);
  static const Color errorBorder = Color(0xFFF2555A);
  static const Color success = Color(0xFF3DD68C);
  static const Color favorite = Color(0xFFFF6B6B);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, Color(0xFF121317), backgroundLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const List<BoxShadow> primaryGlow = [
    BoxShadow(color: Color(0x5C0B66D0), blurRadius: 22, offset: Offset(0, 10)),
  ];
}
