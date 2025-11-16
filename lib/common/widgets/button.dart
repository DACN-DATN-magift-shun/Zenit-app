import 'package:flutter/material.dart';
import 'package:zenit/common/constants/theme/app_sizes.dart';
import 'package:zenit/common/constants/theme/app_theme.dart';

enum AppButtonType {
  primary,
  secondary,
  outline,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonType type;
  final bool isEnabled;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double? elevation;
  final double gap; // spacing between icon and text
  final Color? backgroundColor; // Custom background color
  final Color? foregroundColor; // Custom text/icon color
  final Color? borderColor; // Custom border color

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.type = AppButtonType.primary,
    this.isEnabled = true,
    this.borderRadius = 30,
    this.padding,
    this.width,
    this.height,
    this.elevation,
    this.gap = 8.0,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final isDisabled = !isEnabled || onPressed == null;

    // Xác định style dựa trên type (nếu không có custom color)
    Color finalBackgroundColor;
    Color finalForegroundColor;
    BorderSide? borderSide;
    double buttonElevation;

    switch (type) {
        case AppButtonType.primary:
        finalBackgroundColor = backgroundColor ?? (isDisabled
          ? appColors.primaryMain.withOpacity(0.12)
          : appColors.primaryMain);
        finalForegroundColor = foregroundColor ?? (isDisabled
          ? appColors.neutralTextDisable
          : appColors.primaryText);
        buttonElevation = elevation ?? (isDisabled ? 0 : 2);
        borderSide = borderColor != null
          ? BorderSide(color: borderColor!, width: 1)
          : null;
        break;

        case AppButtonType.secondary:
        finalBackgroundColor = backgroundColor ?? (isDisabled
          ? appColors.neutralSurface.withOpacity(0.12)
          : appColors.secondaryMain);
        finalForegroundColor = foregroundColor ?? (isDisabled
          ? appColors.neutralTextDisable
          : appColors.secondaryText);
        buttonElevation = elevation ?? (isDisabled ? 0 : 1);
        borderSide = borderColor != null
          ? BorderSide(color: borderColor!, width: 1)
          : null;
        break;

      case AppButtonType.outline:
        finalBackgroundColor = backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
        finalForegroundColor = foregroundColor ?? (isDisabled
            ? appColors.neutralTextDisable
            : appColors.primaryMain);
        buttonElevation = elevation ?? 0;
        borderSide = BorderSide(
          color: borderColor ?? (isDisabled
              ? appColors.neutralBorder.withOpacity(0.12)
              : appColors.primaryMain),
          width: 1,
        );
        break;
    }

    // Use LayoutBuilder so we can adapt padding/width to available space
    return LayoutBuilder(
      builder: (context, constraints) {
        // Compute adaptive horizontal padding when no explicit padding passed
        final double horizontal = (() {
          if (padding != null) return 0.0; // we'll use provided padding
          final double pct = constraints.maxWidth * 0.06; // 6% of available width
          if (pct < 12) return 12.0;
          if (pct > 80) return 80.0;
          return pct;
        })();

        final EdgeInsetsGeometry effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: horizontal, vertical: 14);

        // Determine minimumSize only when height or width explicitly provided
        Size? effectiveMinimumSize;
        if (width != null || height != null) {
          effectiveMinimumSize = Size(width ?? 0, height ?? 48);
        }

        final buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: finalBackgroundColor,
          foregroundColor: finalForegroundColor,
          disabledBackgroundColor: finalBackgroundColor,
          disabledForegroundColor: finalForegroundColor,
          elevation: buttonElevation,
          padding: effectivePadding,
          minimumSize: effectiveMinimumSize,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderSide ?? BorderSide.none,
          ),
        );

        // Widget text
        final textWidget = Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        );

        Widget button;
        if (icon != null) {
          // Build manually so we can control gap between icon and text
          button = ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: buttonStyle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: AppSizes.iconM),
                SizedBox(width: gap),
                textWidget,
              ],
            ),
          );
        } else {
          button = ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: buttonStyle,
            child: textWidget,
          );
        }

        // If width explicitly provided, wrap with SizedBox to enforce it.
        if (width != null) {
          return SizedBox(width: width, child: button);
        }

        // On very wide screens, constrain button width to a readable max and center it
        double maxWidthCap = constraints.maxWidth * 0.8;
        if (maxWidthCap > 520) maxWidthCap = 520;
        if (constraints.maxWidth > maxWidthCap && maxWidthCap > 0) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidthCap),
              child: button,
            ),
          );
        }

        return button;
      },
    );
  }
}