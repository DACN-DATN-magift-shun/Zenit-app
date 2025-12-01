import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';

class SingleCategory extends StatelessWidget {
  const SingleCategory({
    super.key,
    this.icon = Symbols.category,
    required this.name,
  });

  final IconData icon;
  final String name;

  @override
  Widget build(BuildContext context) {

    return Material(
      color: Theme.of(context).extension<AppColorExtension>()!.neutralSurface,
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
              color: Theme.of(context).primaryColor, 
              size: AppSizes.textXXXL, 
            ),
            // ---------------------------
            
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).extension<AppColorExtension>()!.neutralTextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}