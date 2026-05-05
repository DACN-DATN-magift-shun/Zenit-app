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
      child: Container(
        padding: EdgeInsets.all(AppSizes.s),
        decoration: BoxDecoration(
          color: AppColors.light.secondaryActive,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        ),
        child: Wrap(
          spacing: AppSizes.s,
          runSpacing: AppSizes.s,
          children: items
              .map(
                (item) => Theme(
                  data: Theme.of(context).copyWith(
                    chipTheme: Theme.of(context).chipTheme.copyWith(
                      backgroundColor: AppColors.light.secondaryActive,
                      disabledColor: Colors.grey.shade200,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                    ),
                  ),
                  child: ActionChip(
                    label: Text(item.label),
                    onPressed: item.enabled ? item.onPressed : null,

                    elevation: 0,
                    pressElevation: 0,
                    shadowColor: Colors.transparent,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadiusLarge,
                      ),
                      side: BorderSide.none,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}