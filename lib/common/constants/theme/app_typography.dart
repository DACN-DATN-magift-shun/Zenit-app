import 'package:flutter/material.dart';
import 'app_sizes.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Inter';

  static TextTheme textThemeLight = TextTheme(
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: AppSizes.textXXXL,
      fontWeight: FontWeight.bold,
      color: AppColors.light.neutralTextPrimary,
    ),
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: AppSizes.textXXL,
      fontWeight: FontWeight.w600,
      color: AppColors.light.neutralTextPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: AppSizes.textL,
      fontWeight: FontWeight.w600,
      color: AppColors.light.primaryHover,
    ),
    titleMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: AppSizes.textS,
      fontWeight: FontWeight.w600,
      color: AppColors.light.primaryActive,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: AppSizes.textM,
      color: AppColors.light.neutralTextPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: AppSizes.textS,
      color: AppColors.light.primaryActive,
    ),
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: AppSizes.textM,
      fontWeight: FontWeight.w500,
      color: AppColors.light.primaryMain,
    ),
  );

  static TextTheme textThemeDark = TextTheme(
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: AppSizes.textXXXL,
      fontWeight: FontWeight.bold,
      color: AppColors.dark.neutralTextPrimary,
    ),
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: AppSizes.textXXL,
      fontWeight: FontWeight.w600,
      color: AppColors.dark.neutralTextPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: AppSizes.textL,
      fontWeight: FontWeight.w600,
      color: AppColors.dark.neutralTextPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: AppSizes.textM,
      color: AppColors.dark.neutralTextPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: AppSizes.textS,
      color: AppColors.dark.neutralTextSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: AppSizes.textM,
      fontWeight: FontWeight.w500,
      color: AppColors.dark.primaryMain,
    ),
  );
}
