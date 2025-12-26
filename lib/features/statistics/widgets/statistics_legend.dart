import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zenit/core/theme/app_colors.dart';
import 'package:zenit/core/theme/app_sizes.dart';

import 'package:zenit/features/statistics/models/statistics_model.dart';

/// Widget hiển thị legend (chú thích) cho pie chart
class StatisticsLegend extends StatelessWidget {
  final List<StatisticsGroupModel> groups;

  // Màu cho từng group type (0-4) - phải khớp với StatisticsPieChart
  static const List<Color> _groupColors = [
    Color(0xFF27AE60), // 0: Neccessary
    Color(0xFF3498DB), // 1: Savings
    Color(0xFF9B59B6), // 2: SelfDevelopment
    Color(0xFF00BCD4), // 3: Entertainment
    Color(0xFF95A5A6), // 4: Other
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

    // Kiểm tra xem có categories không
    final hasCategories = groups.any((g) => g.categories.isNotEmpty);

    return Wrap(
      spacing: AppSizes.m,
      runSpacing: AppSizes.s,
      alignment: WrapAlignment.center,
      children: hasCategories
          ? _getAllCategories().map((catData) => _buildCategoryLegend(context, catData)).toList()
          : groups.map((group) => _buildGroupLegend(context, group)).toList(),
    );
  }

  /// Lấy tất cả categories từ tất cả groups
  List<_CategoryData> _getAllCategories() {
    final Map<String, _CategoryData> categoryMap = {};
    
    for (final group in groups) {
      for (final category in group.categories) {
        final key = '${category.id}_${category.name}';
        if (categoryMap.containsKey(key)) {
          categoryMap[key] = _CategoryData(
            category: category,
            groupType: group.groupType,
            totalAmount: categoryMap[key]!.totalAmount + category.totalAmount,
            percentage: categoryMap[key]!.percentage + category.percentage,
          );
        } else {
          categoryMap[key] = _CategoryData(
            category: category,
            groupType: group.groupType,
            totalAmount: category.totalAmount,
            percentage: category.percentage,
          );
        }
      }
    }
    
    return categoryMap.values.toList();
  }

  /// Build legend item cho category
  Widget _buildCategoryLegend(BuildContext context, _CategoryData catData) {
    final color = catData.groupType < _groupColors.length
        ? _groupColors[catData.groupType]
        : _groupColors.last;

    final formattedAmount = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(catData.totalAmount);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.m,
        vertical: AppSizes.s,
      ),
      decoration: BoxDecoration(
        color: AppColors.light.neutralBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        border: Border.all(
          color: AppColors.light.neutralBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color indicator
          Container(
            width: 12,
            height: 12,
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
                catData.category.name,
                style: TextStyle(
                  fontSize: AppSizes.textXS,
                  color: AppColors.light.neutralTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formattedAmount,
                style: TextStyle(
                  fontSize: AppSizes.textS,
                  color: AppColors.light.neutralTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build legend item cho group (khi không có categories)
  Widget _buildGroupLegend(BuildContext context, StatisticsGroupModel group) {
    final color = group.groupType < _groupColors.length
        ? _groupColors[group.groupType]
        : _groupColors.last;

    final formattedAmount = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    ).format(group.totalAmount);

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
                group.groupName,
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

/// Helper class để lưu thông tin category với groupType
class _CategoryData {
  final StatisticsCategoryModel category;
  final int groupType;
  final int totalAmount;
  final double percentage;

  _CategoryData({
    required this.category,
    required this.groupType,
    required this.totalAmount,
    required this.percentage,
  });
}
