import 'package:flutter/material.dart';
import 'package:zenit/core/l10n/l10n.dart';

class AppConfirmDialog {
  const AppConfirmDialog._();

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    String? cancelText,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(message, style: theme.textTheme.bodyMedium),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          actions: [
            TextButton(
              key: const ValueKey('app-confirm-dialog-cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelText ?? context.l10n.cancel),
            ),
            FilledButton(
              key: const ValueKey('app-confirm-dialog-confirm'),
              style: FilledButton.styleFrom(
                backgroundColor: isDestructive
                    ? colorScheme.error
                    : colorScheme.primary,
                foregroundColor: isDestructive
                    ? colorScheme.onError
                    : colorScheme.onPrimary,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result == true;
  }
}
