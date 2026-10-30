import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark theme (Master specification)
  static const darkBackground = Color(0xFF0B0D17);
  static const darkNavSurface = Color(0xFF111421);
  static const darkCard = Color(0xFF191D2A);
  static const darkCardElevated = Color(0xFF222738);
  static const darkBorder = Color(0xFF262C3D);
  static const darkPrimaryText = Color(0xFFF8FAFC);
  static const darkSecondaryText = Color(0xFF94A3B8);

  // Light theme
  static const lightBackground = Color(0xFFF8FAFC);
  static const lightNavSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCardElevated = Color(0xFFF1F5F9);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightPrimaryText = Color(0xFF0F172A);
  static const lightSecondaryText = Color(0xFF64748B);

  // Accents
  static const primary = Color(0xFF7955F5);
  static const primaryLight = Color(0xFF9B87FF);
  static const secondaryPurple = Color(0xFF8B5CF6);
  static const blue = Color(0xFF3B82F6);
  static const cyan = Color(0xFF06B6D4);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF7955F5), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const purpleGradient = LinearGradient(
    colors: [Color(0xFF7955F5), Color(0xFF9B87FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const insightGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF7955F5), Color(0xFFA855F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
