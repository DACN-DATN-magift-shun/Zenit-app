import 'package:flutter/material.dart';
import 'package:zenit/core/theme/app_colors.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/features/main/models/home_action_item.dart';

/// A reusable grid widget that displays action items.
/// 
/// This widget is designed to be flexible and reusable.
/// It does NOT contain any navigation or business logic - 
/// it simply invokes the callback when an item is tapped.
/// 
/// Usage:
/// ```dart
/// HomeActionGrid(
///   items: myActionItems,
///   onItemTap: (item) {
///     // Handle tap based on item.type
///   },
/// )
/// ```
class HomeActionGrid extends StatelessWidget {
  /// The list of action items to display
  final List<HomeActionItem> items;

  /// Callback invoked when an item is tapped
  final Function(HomeActionItem) onItemTap;

  /// Number of columns in the grid (default: 3)
  final int crossAxisCount;

  /// Spacing between items horizontally
  final double crossAxisSpacing;

  /// Spacing between items vertically
  final double mainAxisSpacing;

  /// Size of the icon container
  final double iconContainerSize;

  /// Size of the icon
  final double iconSize;

  const HomeActionGrid({
    super.key,
    required this.items,
    required this.onItemTap,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 16.0,
    this.iconContainerSize = 70.0,
    this.iconSize = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _ActionGridItem(
          item: items[index],
          onTap: () => onItemTap(items[index]),
          iconContainerSize: iconContainerSize,
          iconSize: iconSize,
        );
      },
    );
  }
}

/// Individual action item widget
class _ActionGridItem extends StatelessWidget {
  final HomeActionItem item;
  final VoidCallback onTap;
  final double iconContainerSize;
  final double iconSize;

  const _ActionGridItem({
    required this.item,
    required this.onTap,
    required this.iconContainerSize,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container with rounded corners (squircle effect)
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: item.useGradient ? null : item.backgroundColor,
              gradient: item.useGradient && item.gradientColors != null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: item.gradientColors!,
                    )
                  : null,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
              boxShadow: [
                BoxShadow(
                  color: item.backgroundColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              item.icon,
              size: iconSize,
              color: item.iconColor,
            ),
          ),
          const SizedBox(height: AppSizes.m),
          // Title text
          Text(
            item.title,
            style: TextStyle(
              fontSize: AppSizes.textS,
              fontWeight: FontWeight.w500,
              color: AppColors.light.neutralTextPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
