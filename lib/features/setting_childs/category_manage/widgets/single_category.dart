import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';

class SingleCategory extends StatelessWidget {
  const SingleCategory({
    super.key,
    this.icon = Symbols.category,
    required this.name,
    this.iconColor,
    this.backgroundColor,
    this.isSelected = false,
  });

  final IconData icon;
  final String name;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorExtension>()!;
    final bgColor = backgroundColor ?? theme.colorScheme.secondaryContainer;
    final icColor = iconColor ?? theme.colorScheme.onSecondaryContainer;
    final borderColor = isSelected ? colors.primaryMain : Colors.transparent;

    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: isSelected ? 2 : 0),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Icon(
                    icon,
                    fill: 1.0,
                    weight: 400,
                    grade: 0.25,
                    color: icColor,
                    size: AppSizes.textXXXL,
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: colors.primaryMain,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Symbols.check_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.2,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
