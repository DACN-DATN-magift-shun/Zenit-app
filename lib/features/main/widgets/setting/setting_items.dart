import 'package:flutter/material.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/icon_with_circle_background.dart';

class SettingItem extends StatelessWidget {
  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,    
  });
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).extension<AppColorExtension>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSizes.l, horizontal: AppSizes.s),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconWithCircleBackground(
              icon: icon,
              size: 48.0,
              backgroundColor: color.primaryMain,
              iconColor: Colors.white,
            ),
            SizedBox(width: AppSizes.l),
            Text(
              title,
              style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle()).copyWith(
                    color: color.neutralTextPrimary, fontWeight: FontWeight.w800
                  ),
            ),
          ],
        ),
      ),
    );
  }
}