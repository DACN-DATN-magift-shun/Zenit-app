import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zenit/core/theme/app_colors.dart';
import 'package:zenit/core/theme/app_sizes.dart';

import 'package:zenit/features/statistics/models/statistics_model.dart';

/// Widget hiển thị chú thích cho pie chart
class StatisticsLegend extends StatelessWidget {
  final List<StatisticsGroupModel> groups;

  // Màu cho từng group type (0-5) - phải khớp với StatisticsPieChart
  static const List<Color> _groupColors = [
    Color(0xFF27AE60), // 0: Necessary
    Color(0xFF3498DB), // 1: Assets
    Color(0xFF9B59B6), // 2: SelfDevelopment
    Color(0xFF00BCD4), // 3: Entertainment
    Color(0xFF95A5A6), // 4: Giving
    Color(0xFFF39C12), // 5: Income
  ];

  const StatisticsLegend({
    super.key,
    required this.groups,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: AppSizes.m,
      runSpacing: AppSizes.s,
      alignment: WrapAlignment.center,
      children: groups.map((group) => _buildGroupLegend(context, group)).toList(),
    );
  }

  /// Build legend item cho group
  Widget _buildGroupLegend(BuildContext context, StatisticsGroupModel group) {
    final color = group.groupType < _groupColors.length
        ? _groupColors[group.groupType]
        : _groupColors.last;

    final formattedAmount = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    ).format(group.totalAmount);

    final groupLabel = group.groupName;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.m,
        vertical: AppSizes.s,
      ),
      decoration: BoxDecoration(
        color: AppColors.light.neutralBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall),
        border: Border.all(
          color: AppColors.light.neutralBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color indicator
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(

              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSizes.s),
          // Label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                groupLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.light.neutralTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
              ),
              const SizedBox(height: 2),
              Text(
                formattedAmount,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.light.neutralTextPrimary,
                        fontWeight: FontWeight.w500,
              ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
