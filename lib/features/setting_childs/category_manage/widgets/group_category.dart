import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';

class GroupCategory extends StatelessWidget {
  const GroupCategory({
    super.key,
    required this.title,
    required this.titleChipColor,
    required this.chipIcon,
    required this.items,
    this.onAdd,
  });

  final String title;
  final Color titleChipColor;
  final IconData chipIcon;
  final List<Widget> items;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.s),
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<AppColorExtension>()!.neutralSurface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        // boxShadow: [
        //   BoxShadow(
        //     blurRadius: 12,
        //     color: Theme.of(context).extension<AppColorExtension>()!.primaryShade,
        //   )
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE CHIP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: titleChipColor,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(chipIcon, size: AppSizes.textXL, color: Theme.of(context).extension<AppColorExtension>()!.neutralTextPrimary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).extension<AppColorExtension>()!.neutralTextPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ICON LIST
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              ...items,
              _buildAddButton(context),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.add_rounded,
              fill: 1.0,   
              weight: 400, 
              grade: 0.25,
              size: AppSizes.textXXXL,
              color: Theme.of(context).extension<AppColorExtension>()!.primaryMain,
            ),
          ],
        ),
      ),
    );
  }
}
