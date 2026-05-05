import 'package:flutter/material.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';

class SingleMoneySource extends StatelessWidget {
  const SingleMoneySource({
    super.key,
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.onTap,
  });

  final String name;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        height: 140,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
              ),
              child: Icon(icon, size: AppSizes.iconL, color: iconColor),
            ),
            const SizedBox(height: AppSizes.s),
            SizedBox(
              height: 36,
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.neutralTextPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: AppSizes.textS,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
