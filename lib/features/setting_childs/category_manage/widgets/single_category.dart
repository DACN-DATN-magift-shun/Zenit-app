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
  });

  final IconData icon;
  final String name;
  final Color? iconColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final bgColor = backgroundColor ?? colors.neutralSurface;
    final icColor = iconColor ?? Theme.of(context).primaryColor;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall), 
      child: Container(
        padding: const EdgeInsets.all(AppSizes.s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              fill: 1.0,   
              weight: 400, 
              grade: 0.25, // Độ tinh chỉnh nét
              color: icColor, 
              size: AppSizes.textXXXL, 
            ),
            // ---------------------------
            
            // const SizedBox(height: 6),
            // Flexible(
            //   child: Text(
            //     name,
            //     maxLines: 2,
            //     overflow: TextOverflow.ellipsis,
            //     textAlign: TextAlign.center,
            //     style: Theme.of(context).textTheme.bodySmall?.copyWith(
            //       fontWeight: FontWeight.w800,
            //       color: colors.neutralTextPrimary,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}