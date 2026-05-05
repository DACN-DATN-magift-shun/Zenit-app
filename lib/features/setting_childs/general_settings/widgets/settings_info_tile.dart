import 'package:flutter/material.dart';
import 'package:zenit/core/theme/app_colors.dart';

class SettingsInfoTile extends StatelessWidget {
  final String title;
  final String value;

  const SettingsInfoTile({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.light.neutralTextSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
