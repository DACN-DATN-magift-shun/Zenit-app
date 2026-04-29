import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';

enum AppFlashType { success, error, warning, info }

class AppFlash {
  AppFlash._();

  static void success(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      type: AppFlashType.success,
      duration: duration,
    );
  }

  static void error(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      type: AppFlashType.error,
      duration: duration,
    );
  }

  static void warning(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      type: AppFlashType.warning,
      duration: duration,
    );
  }

  static void info(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      type: AppFlashType.info,
      duration: duration,
    );
  }

  static Future<void> _show(
    BuildContext context, {
    required String message,
    required AppFlashType type,
    Duration? duration,
  }) async {
    if (!context.mounted) return;
    if (_isWidgetTestEnvironment()) return;

    final colors = Theme.of(context).extension<AppColorExtension>();
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomMargin = AppSizes.l + mediaQuery.viewPadding.bottom + 72;

    final style = _resolveStyle(type, colors);

    await showFlash<void>(
      context: context,
      duration: duration ?? _defaultDuration(type),
      builder: (context, controller) {
        return FlashBar(
          controller: controller,
          position: FlashPosition.bottom,
          behavior: FlashBehavior.floating,
          margin: EdgeInsets.fromLTRB(
            AppSizes.l,
            AppSizes.l,
            AppSizes.l,
            bottomMargin,
          ),
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          backgroundColor: style.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
          ),
          icon: _buildIcon(style),
          shouldIconPulse: false,
          contentTextStyle: textTheme.bodyMedium?.copyWith(
            color: style.text,
            fontWeight: FontWeight.w600,
          ),
          content: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  static bool _isWidgetTestEnvironment() {
    final binding = WidgetsBinding.instance;
    if (binding == null) {
      return false;
    }

    return binding.runtimeType.toString().contains('TestWidgetsFlutterBinding');
  }

  static Widget _buildIcon(_AppFlashStyle style) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: style.iconColor.withValues(alpha: 0.14),
      ),
      child: Icon(
        style.icon,
        color: style.iconColor,
        size: AppSizes.iconS,
      ),
    );
  }

  static Duration _defaultDuration(AppFlashType type) {
    switch (type) {
      case AppFlashType.success:
      case AppFlashType.info:
        return const Duration(seconds: 2);
      case AppFlashType.warning:
        return const Duration(milliseconds: 2500);
      case AppFlashType.error:
        return const Duration(seconds: 3);
    }
  }

  static _AppFlashStyle _resolveStyle(AppFlashType type, AppColorExtension? colors) {
    final fallback = colors == null;

    switch (type) {
      case AppFlashType.success:
        return _AppFlashStyle(
          background: fallback ? const Color(0xFFE6F6EA) : colors.successBackground,
          text: fallback ? const Color(0xFF1B4F2E) : colors.successText,
          iconColor: fallback ? const Color(0xFF27AE60) : colors.successIcon,
          icon: Icons.check_circle_rounded,
        );
      case AppFlashType.error:
        return _AppFlashStyle(
          background: fallback ? const Color(0xFFFDECEA) : colors.errorBackground,
          text: fallback ? const Color(0xFF5C0B0B) : colors.errorText,
          iconColor: fallback ? const Color(0xFFFF4D4F) : colors.errorIcon,
          icon: Icons.error_rounded,
        );
      case AppFlashType.warning:
        return _AppFlashStyle(
          background: fallback ? const Color(0xFFFFF4E5) : colors.warningBackground,
          text: fallback ? const Color(0xFF6D4A00) : colors.warningText,
          iconColor: fallback ? const Color(0xFFFFA000) : colors.warningIcon,
          icon: Icons.warning_rounded,
        );
      case AppFlashType.info:
        return _AppFlashStyle(
          background: fallback ? const Color(0xFFE6FAFF) : colors.infoBackground,
          text: fallback ? const Color(0xFF004B50) : colors.infoText,
          iconColor: fallback ? const Color(0xFF00BCD4) : colors.infoIcon,
          icon: Icons.info_rounded,
        );
    }
  }
}

class _AppFlashStyle {
  const _AppFlashStyle({
    required this.background,
    required this.text,
    required this.iconColor,
    required this.icon,
  });

  final Color background;
  final Color text;
  final Color iconColor;
  final IconData icon;
}
