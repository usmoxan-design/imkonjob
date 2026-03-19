import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Light theme ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF1967D2);
  static const Color primaryLight = Color(0xFFE8F0FE);

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textHint = Color(0xFF9AA0A6);

  static const Color border = Color(0xFFDADCE0);
  static const Color divider = Color(0xFFDADCE0);
  static const Color muted = Color(0xFFF1F3F4);

  static const Color success = Color(0xFF34A853);
  static const Color successLight = Color(0xFFE6F4EA);
  static const Color error = Color(0xFFD93025);
  static const Color errorLight = Color(0xFFFCE8E6);
  static const Color warning = Color(0xFFF29900);
  static const Color warningLight = Color(0xFFFEF7E0);

  static const Color yellow = Color(0xFFFBBC04);
  static const Color purple = Color(0xFF673AB7);
  static const Color purpleLight = Color(0xFFEDE7F6);
  static const Color teal = Color(0xFF00897B);
  static const Color tealLight = Color(0xFFE0F2F1);
  static const Color orange = Color(0xFFE8710A);
  static const Color orangeLight = Color(0xFFFCEEDE);

  static const Color grey100 = Color(0xFFF8F9FA);
  static const Color grey200 = Color(0xFFF1F3F4);
  static const Color grey300 = Color(0xFFDADCE0);
  static const Color grey400 = Color(0xFFBDC1C6);
  static const Color grey500 = Color(0xFF9AA0A6);
  static const Color grey600 = Color(0xFF80868B);
  static const Color grey700 = Color(0xFF5F6368);
  static const Color grey800 = Color(0xFF3C4043);
  static const Color grey900 = Color(0xFF202124);

  static const Color shimmerBase = Color(0xFFE8EAED);
  static const Color shimmerHighlight = Color(0xFFF8F9FA);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A73E8), Color(0xFF1967D2)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1557B0), Color(0xFF1A73E8), Color(0xFF4285F4)],
  );

  // ── Dark theme ───────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F1014);
  static const Color darkSurface = Color(0xFF1C1E24);
  static const Color darkSurface2 = Color(0xFF252830);
  static const Color darkBorder = Color(0xFF2E3138);
  static const Color darkMuted = Color(0xFF1C1E24);
  static const Color darkTextPrimary = Color(0xFFE8EAED);
  static const Color darkTextSecondary = Color(0xFF9AA0A6);
  static const Color darkTextHint = Color(0xFF5F6368);
  static const Color darkPrimaryLight = Color(0xFF1A2C4A);
  static const Color darkShimmerBase = Color(0xFF2E3138);
  static const Color darkShimmerHighlight = Color(0xFF3C4043);
}

// ── Context extension for adaptive colors ────────────────────────────────
extension AppColorsX on BuildContext {
  bool get isDark =>
      Theme.of(this).brightness == Brightness.dark;

  Color get bg =>
      isDark ? AppColors.darkBackground : AppColors.background;
  Color get surf =>
      isDark ? AppColors.darkSurface : AppColors.surface;
  Color get surf2 =>
      isDark ? AppColors.darkSurface2 : AppColors.grey100;
  Color get borderClr =>
      isDark ? AppColors.darkBorder : AppColors.border;
  Color get mutedClr =>
      isDark ? AppColors.darkMuted : AppColors.muted;
  Color get txtPrimary =>
      isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get txtSecondary =>
      isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get primaryLightClr =>
      isDark ? AppColors.darkPrimaryLight : AppColors.primaryLight;
}
