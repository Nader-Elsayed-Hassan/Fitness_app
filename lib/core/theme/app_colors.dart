import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF0066FF);
  static const Color primaryLight = Color(0xFF3385FF);
  static const Color primaryDark = Color(0xFF0047B3);

  // Background
  static const Color background = Color(0xFF101415);
  static const Color surface = Color(0xFF1A1F20);
  static const Color surfaceVariant = Color(0xFF242A2B);
  static const Color cardBg = Color(0xFF1E2425);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A9BA8);
  static const Color textMuted = Color(0xFF4A5568);

  // Accent
  static const Color accent = Color(0xFF00E5FF);
  static const Color accentGreen = Color(0xFF00C853);
  static const Color accentOrange = Color(0xFFFF6D00);
  static const Color accentPurple = Color(0xFF7C4DFF);

  // Border
  static const Color border = Color(0xFF2A3235);
  static const Color borderLight = Color(0xFF3A4548);

  // Gradient
  static const List<Color> primaryGradient = [
    Color(0xFF0066FF),
    Color(0xFF00E5FF),
  ];
  static const List<Color> darkGradient = [
    Color(0xFF1A1F20),
    Color(0xFF101415),
  ];
  static const List<Color> cardGradient = [
    Color(0xFF1E2A3A),
    Color(0xFF1A1F20),
  ];
}
