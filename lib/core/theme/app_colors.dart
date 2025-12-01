import 'package:flutter/material.dart';

/// Centralized color palettes for the app.
/// Usage:
///   AppColors.light.primaryMain
///   AppColors.dark.primaryMain  // fill dark values later
class AppColors {
  AppColors._();

  static const LightPalette light = LightPalette();
  static const DarkPalette dark = DarkPalette();
}

class LightPalette {
  const LightPalette();

  // Light - Primary
  final Color primaryMain = const Color(0xFF2196F3);
  final Color primaryHover = const Color(0xFF0A5CA3);
  final Color primaryActive = const Color(0xFF4DA8F5);
  final Color primaryText = const Color(0xFFF4FBFF);
  final Color primarySubtext = const Color(0xFF7FC3F5);
  final Color primaryShade = const Color(0xFF023E66);

  // Light - Secondary
  final Color secondaryMain = const Color(0xFFEEF5F8);
  final Color secondaryHover = const Color(0xFF00A8FF);
  final Color secondaryActive = const Color(0xFFBFE9FF);
  final Color secondaryText = const Color(0xFF053B45);
  final Color secondarySubtext = const Color(0xFF026693);
  final Color secondaryShade = const Color(0xFF0077A8);

  // Neutral
  final Color neutralBackground = const Color(0xFFFFFFFF);
  final Color neutralSurface = const Color(0xFFE9E9E9);
  final Color neutralBorder = const Color(0xFFE6E9EE);
  final Color neutralTextDisable = const Color(0xFFBDBDBD);
  final Color neutralTextSecondary = const Color(0xFF757575);
  final Color neutralTextPrimary = const Color(0xFF111111);

  // Semantic
  final Color successBackground = const Color(0xFFE6F6EA);
  final Color successText = const Color(0xFF1B4F2E);
  final Color successIcon = const Color(0xFF27AE60);

  final Color errorBackground = const Color(0xFFFDECEA);
  final Color errorText = const Color(0xFF5C0B0B);
  final Color errorIcon = const Color(0xFFFF4D4F);

  final Color warningBackground = const Color(0xFFFFF4E5);
  final Color warningText = const Color(0xFF6D4A00);
  final Color warningIcon = const Color(0xFFFFA000);

  final Color infoBackground = const Color(0xFFE6FAFF);
  final Color infoText = const Color(0xFF004B50);
  final Color infoIcon = const Color(0xFF00BCD4);
}

class DarkPalette {
  const DarkPalette();

  // TODO: Thay các giá trị màu cho theme dark khi có design.
  // Hiện để tạm giống light để dễ tham chiếu.
  final Color primaryMain = const Color(0xFF0B79D1);
  final Color primaryHover = const Color(0xFF0A5CA3);
  final Color primaryActive = const Color(0xFF4DA8F5);
  final Color primaryText = const Color(0xFFF4FBFF);
  final Color primarySubtext = const Color(0xFF7FC3F5);
  final Color primaryShade = const Color(0xFF023E66);

  final Color secondaryMain = const Color(0xFFEEF5F8);
  final Color secondaryHover = const Color(0xFF00A8FF);
  final Color secondaryActive = const Color(0xFFBFE9FF);
  final Color secondaryText = const Color(0xFF053B45);
  final Color secondarySubtext = const Color(0xFF5AAFD0);
  final Color secondaryShade = const Color(0xFF0077A8);

  final Color neutralBackground = const Color(0xFF0A0A0A);
  final Color neutralSurface = const Color(0xFF121212);
  final Color neutralBorder = const Color(0xFF2A2A2A);
  final Color neutralTextDisable = const Color(0xFF6B6B6B);
  final Color neutralTextSecondary = const Color(0xFF9E9E9E);
  final Color neutralTextPrimary = const Color(0xFFFFFFFF);

  final Color successBackground = const Color(0xFF092612);
  final Color successText = const Color(0xFF7DDC99);
  final Color successIcon = const Color(0xFF27AE60);

  final Color errorBackground = const Color(0xFF2A0A0A);
  final Color errorText = const Color(0xFFFFB4B4);
  final Color errorIcon = const Color(0xFFFF4D4F);

  final Color warningBackground = const Color(0xFF2A1A00);
  final Color warningText = const Color(0xFFFFD599);
  final Color warningIcon = const Color(0xFFFFA000);

  final Color infoBackground = const Color(0xFF002426);
  final Color infoText = const Color(0xFF8FEAFF);
  final Color infoIcon = const Color(0xFF00BCD4);
}
