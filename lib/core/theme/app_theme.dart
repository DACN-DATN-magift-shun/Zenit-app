import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_sizes.dart';
import 'app_typography.dart';

const Color _inputFillColor = Color(0xFFD2E4FF);

/// Custom ThemeExtension để lưu tất cả màu trong AppColors
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  final Color primaryMain;
  final Color primaryHover;
  final Color primaryActive;
  final Color primaryText;
  final Color primarySubtext;
  final Color primaryShade;

  final Color secondaryMain;
  final Color secondaryHover;
  final Color secondaryActive;
  final Color secondaryText;
  final Color secondarySubtext;
  final Color secondaryShade;

  final Color neutralBackground;
  final Color neutralSurface;
  final Color neutralBorder;
  final Color neutralTextDisable;
  final Color neutralTextSecondary;
  final Color neutralTextPrimary;

  final Color successBackground;
  final Color successText;
  final Color successIcon;

  final Color errorBackground;
  final Color errorText;
  final Color errorIcon;

  final Color warningBackground;
  final Color warningText;
  final Color warningIcon;

  final Color infoBackground;
  final Color infoText;
  final Color infoIcon;

  const AppColorExtension({
    required this.primaryMain,
    required this.primaryHover,
    required this.primaryActive,
    required this.primaryText,
    required this.primarySubtext,
    required this.primaryShade,
    required this.secondaryMain,
    required this.secondaryHover,
    required this.secondaryActive,
    required this.secondaryText,
    required this.secondarySubtext,
    required this.secondaryShade,
    required this.neutralBackground,
    required this.neutralSurface,
    required this.neutralBorder,
    required this.neutralTextDisable,
    required this.neutralTextSecondary,
    required this.neutralTextPrimary,
    required this.successBackground,
    required this.successText,
    required this.successIcon,
    required this.errorBackground,
    required this.errorText,
    required this.errorIcon,
    required this.warningBackground,
    required this.warningText,
    required this.warningIcon,
    required this.infoBackground,
    required this.infoText,
    required this.infoIcon,
  });

  @override
  AppColorExtension copyWith({
    Color? primaryMain,
    Color? primaryHover,
    Color? primaryActive,
    Color? primaryText,
    Color? primarySubtext,
    Color? primaryShade,
    Color? secondaryMain,
    Color? secondaryHover,
    Color? secondaryActive,
    Color? secondaryText,
    Color? secondarySubtext,
    Color? secondaryShade,
    Color? neutralBackground,
    Color? neutralSurface,
    Color? neutralBorder,
    Color? neutralTextDisable,
    Color? neutralTextSecondary,
    Color? neutralTextPrimary,
    Color? successBackground,
    Color? successText,
    Color? successIcon,
    Color? errorBackground,
    Color? errorText,
    Color? errorIcon,
    Color? warningBackground,
    Color? warningText,
    Color? warningIcon,
    Color? infoBackground,
    Color? infoText,
    Color? infoIcon,
  }) {
    return AppColorExtension(
      primaryMain: primaryMain ?? this.primaryMain,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryActive: primaryActive ?? this.primaryActive,
      primaryText: primaryText ?? this.primaryText,
      primarySubtext: primarySubtext ?? this.primarySubtext,
      primaryShade: primaryShade ?? this.primaryShade,
      secondaryMain: secondaryMain ?? this.secondaryMain,
      secondaryHover: secondaryHover ?? this.secondaryHover,
      secondaryActive: secondaryActive ?? this.secondaryActive,
      secondaryText: secondaryText ?? this.secondaryText,
      secondarySubtext: secondarySubtext ?? this.secondarySubtext,
      secondaryShade: secondaryShade ?? this.secondaryShade,
      neutralBackground: neutralBackground ?? this.neutralBackground,
      neutralSurface: neutralSurface ?? this.neutralSurface,
      neutralBorder: neutralBorder ?? this.neutralBorder,
      neutralTextDisable: neutralTextDisable ?? this.neutralTextDisable,
      neutralTextSecondary: neutralTextSecondary ?? this.neutralTextSecondary,
      neutralTextPrimary: neutralTextPrimary ?? this.neutralTextPrimary,
      successBackground: successBackground ?? this.successBackground,
      successText: successText ?? this.successText,
      successIcon: successIcon ?? this.successIcon,
      errorBackground: errorBackground ?? this.errorBackground,
      errorText: errorText ?? this.errorText,
      errorIcon: errorIcon ?? this.errorIcon,
      warningBackground: warningBackground ?? this.warningBackground,
      warningText: warningText ?? this.warningText,
      warningIcon: warningIcon ?? this.warningIcon,
      infoBackground: infoBackground ?? this.infoBackground,
      infoText: infoText ?? this.infoText,
      infoIcon: infoIcon ?? this.infoIcon,
    );
  }

  @override
  AppColorExtension lerp(ThemeExtension<AppColorExtension>? other, double t) {
    if (other is! AppColorExtension) return this;
    return AppColorExtension(
      primaryMain: Color.lerp(primaryMain, other.primaryMain, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primaryActive: Color.lerp(primaryActive, other.primaryActive, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      primarySubtext: Color.lerp(primarySubtext, other.primarySubtext, t)!,
      primaryShade: Color.lerp(primaryShade, other.primaryShade, t)!,
      secondaryMain: Color.lerp(secondaryMain, other.secondaryMain, t)!,
      secondaryHover: Color.lerp(secondaryHover, other.secondaryHover, t)!,
      secondaryActive: Color.lerp(secondaryActive, other.secondaryActive, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      secondarySubtext: Color.lerp(
        secondarySubtext,
        other.secondarySubtext,
        t,
      )!,
      secondaryShade: Color.lerp(secondaryShade, other.secondaryShade, t)!,
      neutralBackground: Color.lerp(
        neutralBackground,
        other.neutralBackground,
        t,
      )!,
      neutralSurface: Color.lerp(neutralSurface, other.neutralSurface, t)!,
      neutralBorder: Color.lerp(neutralBorder, other.neutralBorder, t)!,
      neutralTextDisable: Color.lerp(
        neutralTextDisable,
        other.neutralTextDisable,
        t,
      )!,
      neutralTextSecondary: Color.lerp(
        neutralTextSecondary,
        other.neutralTextSecondary,
        t,
      )!,
      neutralTextPrimary: Color.lerp(
        neutralTextPrimary,
        other.neutralTextPrimary,
        t,
      )!,
      successBackground: Color.lerp(
        successBackground,
        other.successBackground,
        t,
      )!,
      successText: Color.lerp(successText, other.successText, t)!,
      successIcon: Color.lerp(successIcon, other.successIcon, t)!,
      errorBackground: Color.lerp(errorBackground, other.errorBackground, t)!,
      errorText: Color.lerp(errorText, other.errorText, t)!,
      errorIcon: Color.lerp(errorIcon, other.errorIcon, t)!,
      warningBackground: Color.lerp(
        warningBackground,
        other.warningBackground,
        t,
      )!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      warningIcon: Color.lerp(warningIcon, other.warningIcon, t)!,
      infoBackground: Color.lerp(infoBackground, other.infoBackground, t)!,
      infoText: Color.lerp(infoText, other.infoText, t)!,
      infoIcon: Color.lerp(infoIcon, other.infoIcon, t)!,
    );
  }
}

/// ================= LIGHT THEME =================
final ThemeData lightTheme = ThemeData(
  iconTheme: const IconThemeData(color: Colors.black),
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.light.neutralBackground,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.light.primaryMain,
    onPrimary: AppColors.light.primaryText,
    secondary: AppColors.light.secondaryMain,
    onSecondary: AppColors.light.secondaryText,
    error: AppColors.light.errorIcon,
    onError: AppColors.light.errorText,
    background: AppColors.light.neutralBackground,
    onBackground: AppColors.light.neutralTextPrimary,
    surface: AppColors.light.neutralSurface,
    onSurface: AppColors.light.neutralTextPrimary,
  ),
  textTheme: AppTypography.textThemeLight,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.light.primaryMain,
    foregroundColor: AppColors.light.primaryText,
    centerTitle: true,
    elevation: 0,
    titleTextStyle: AppTypography.textThemeLight.titleLarge,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _inputFillColor,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSizes.m,
      vertical: AppSizes.s,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      borderSide: BorderSide(color: AppColors.light.neutralBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      borderSide: BorderSide(color: AppColors.light.primaryMain, width: 2),
    ),
    hintStyle: TextStyle(
      color: AppColors.light.neutralTextSecondary,
      fontWeight: FontWeight.w400,
    ),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    titleTextStyle: AppTypography.textThemeLight.titleLarge?.copyWith(
      color: AppColors.light.neutralTextPrimary,
      fontWeight: FontWeight.w700,
    ),
    contentTextStyle: AppTypography.textThemeLight.bodyMedium?.copyWith(
      color: AppColors.light.neutralTextPrimary,
    ),
  ),
  extensions: [
    AppColorExtension(
      primaryMain: AppColors.light.primaryMain,
      primaryHover: AppColors.light.primaryHover,
      primaryActive: AppColors.light.primaryActive,
      primaryText: AppColors.light.primaryText,
      primarySubtext: AppColors.light.primarySubtext,
      primaryShade: const Color.fromARGB(137, 116, 141, 157),
      secondaryMain: AppColors.light.secondaryMain,
      secondaryHover: AppColors.light.secondaryHover,
      secondaryActive: AppColors.light.secondaryActive,
      secondaryText: AppColors.light.secondaryText,
      secondarySubtext: AppColors.light.secondarySubtext,
      secondaryShade: AppColors.light.secondaryShade,
      neutralBackground: AppColors.light.neutralBackground,
      neutralSurface: AppColors.light.neutralSurface,
      neutralBorder: AppColors.light.neutralBorder,
      neutralTextDisable: AppColors.light.neutralTextDisable,
      neutralTextSecondary: AppColors.light.neutralTextSecondary,
      neutralTextPrimary: AppColors.light.neutralTextPrimary,
      successBackground: AppColors.light.successBackground,
      successText: AppColors.light.successText,
      successIcon: AppColors.light.successIcon,
      errorBackground: AppColors.light.errorBackground,
      errorText: AppColors.light.errorText,
      errorIcon: AppColors.light.errorIcon,
      warningBackground: AppColors.light.warningBackground,
      warningText: AppColors.light.warningText,
      warningIcon: AppColors.light.warningIcon,
      infoBackground: AppColors.light.infoBackground,
      infoText: AppColors.light.infoText,
      infoIcon: AppColors.light.infoIcon,
    ),
  ],
);

/// ================= DARK THEME =================
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.dark.neutralBackground,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.dark.primaryMain,
    onPrimary: AppColors.dark.primaryText,
    secondary: AppColors.dark.secondaryMain,
    onSecondary: AppColors.dark.secondaryText,
    error: AppColors.dark.errorIcon,
    onError: AppColors.dark.errorText,
    background: AppColors.dark.neutralBackground,
    onBackground: AppColors.dark.neutralTextPrimary,
    surface: AppColors.dark.neutralSurface,
    onSurface: AppColors.dark.neutralTextPrimary,
  ),
  textTheme: AppTypography.textThemeDark,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.dark.primaryShade,
    foregroundColor: AppColors.dark.primaryText,
    centerTitle: true,
    elevation: 0,
    titleTextStyle: AppTypography.textThemeDark.titleLarge,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _inputFillColor,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSizes.m,
      vertical: AppSizes.s,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      borderSide: BorderSide(color: AppColors.dark.neutralBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      borderSide: BorderSide(color: AppColors.dark.primaryMain, width: 2),
    ),
    hintStyle: TextStyle(
      color: AppColors.dark.neutralTextSecondary,
      fontWeight: FontWeight.w400,
    ),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    titleTextStyle: AppTypography.textThemeDark.titleLarge?.copyWith(
      color: AppColors.light.neutralTextPrimary,
      fontWeight: FontWeight.w700,
    ),
    contentTextStyle: AppTypography.textThemeDark.bodyMedium?.copyWith(
      color: AppColors.light.neutralTextPrimary,
    ),
  ),
  extensions: [
    AppColorExtension(
      primaryMain: AppColors.dark.primaryMain,
      primaryHover: AppColors.dark.primaryHover,
      primaryActive: AppColors.dark.primaryActive,
      primaryText: AppColors.dark.primaryText,
      primarySubtext: AppColors.dark.primarySubtext,
      primaryShade: AppColors.dark.primaryShade,
      secondaryMain: AppColors.dark.secondaryMain,
      secondaryHover: AppColors.dark.secondaryHover,
      secondaryActive: AppColors.dark.secondaryActive,
      secondaryText: AppColors.dark.secondaryText,
      secondarySubtext: AppColors.dark.secondarySubtext,
      secondaryShade: AppColors.dark.secondaryShade,
      neutralBackground: AppColors.dark.neutralBackground,
      neutralSurface: AppColors.dark.neutralSurface,
      neutralBorder: AppColors.dark.neutralBorder,
      neutralTextDisable: AppColors.dark.neutralTextDisable,
      neutralTextSecondary: AppColors.dark.neutralTextSecondary,
      neutralTextPrimary: AppColors.dark.neutralTextPrimary,
      successBackground: AppColors.dark.successBackground,
      successText: AppColors.dark.successText,
      successIcon: AppColors.dark.successIcon,
      errorBackground: AppColors.dark.errorBackground,
      errorText: AppColors.dark.errorText,
      errorIcon: AppColors.dark.errorIcon,
      warningBackground: AppColors.dark.warningBackground,
      warningText: AppColors.dark.warningText,
      warningIcon: AppColors.dark.warningIcon,
      infoBackground: AppColors.dark.infoBackground,
      infoText: AppColors.dark.infoText,
      infoIcon: AppColors.dark.infoIcon,
    ),
  ],
);
