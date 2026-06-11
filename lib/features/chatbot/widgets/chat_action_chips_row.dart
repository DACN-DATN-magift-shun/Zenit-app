import 'package:flutter/material.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_colors.dart';

class ChatActionChipItem {
  const ChatActionChipItem({
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;
}

class ChatActionChipsRow extends StatelessWidget {
  const ChatActionChipsRow({
    super.key,
    required this.items,
    this.alignment = Alignment.centerLeft,
  });

  final List<ChatActionChipItem> items;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: alignment == Alignment.centerRight
            ? CrossAxisAlignment.end
            : (alignment == Alignment.center
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start),
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.elementSpacing),
            child: ActionChip(
              label: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.s,
                  vertical: AppSizes.xs,
                ),
                child: Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: item.enabled
                            ? AppColors.light.primaryMain
                            : AppColors.light.neutralTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              onPressed: item.enabled ? item.onPressed : null,
              backgroundColor: Colors.white,
              disabledColor: Colors.grey.shade100,
              elevation: 0,
              pressElevation: 0,
              shadowColor: Colors.transparent,
              side: BorderSide(
                color: item.enabled
                    ? AppColors.light.primaryMain.withValues(alpha: 0.4)
                    : Colors.grey.shade300,
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}