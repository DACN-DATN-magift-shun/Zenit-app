import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:zenit/core/theme/app_colors.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/features/statistics/models/statistics_model.dart';

/// Widget hiển thị pie chart cho thống kê
class StatisticsPieChart extends StatefulWidget {
  final List<StatisticsGroupModel> groups;

  const StatisticsPieChart({
    super.key,
    required this.groups,
  });

  @override
  State<StatisticsPieChart> createState() => _StatisticsPieChartState();
}

class _StatisticsPieChartState extends State<StatisticsPieChart> {
  int touchedIndex = -1;

  // Màu cho từng group type (0-4)
  List<Color> get _groupColors => [
    const Color(0xFF27AE60), // 0: Neccessary - Xanh lá
    const Color(0xFF3498DB), // 1: Savings - Xanh dương
    const Color(0xFF9B59B6), // 2: SelfDevelopment - Tím
    const Color(0xFF00BCD4), // 3: Entertainment - Xanh ngọc
    const Color(0xFF95A5A6), // 4: Other - Xám
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.groups.isEmpty) {
      return _buildEmptyState();
    }

    // Kiểm tra xem có categories không
    final hasCategories = widget.groups.any((g) => g.categories.isNotEmpty);

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: hasCategories ? _buildCategorySections() : _buildGroupSections(),
        ),
      ),
    );
  }

  /// Build sections theo categories (khi có categories)
  List<PieChartSectionData> _buildCategorySections() {
    final allCategories = _getAllCategories();
    final List<PieChartSectionData> sections = [];
    
    for (int i = 0; i < allCategories.length; i++) {
      final categoryData = allCategories[i];
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 65.0 : 55.0;
      final fontSize = isTouched ? AppSizes.textM : AppSizes.textS;

      final color = categoryData.groupType < _groupColors.length
          ? _groupColors[categoryData.groupType]
          : _groupColors.last;

      sections.add(
        PieChartSectionData(
          color: color,
          value: categoryData.percentage,
          title: '${categoryData.percentage.toStringAsFixed(1)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [
              Shadow(color: Colors.black26, blurRadius: 2),
            ],
          ),
        ),
      );
    }

    return sections;
  }

  /// Build sections theo groups (khi không có categories)
  List<PieChartSectionData> _buildGroupSections() {
    final List<PieChartSectionData> sections = [];
    
    for (int i = 0; i < widget.groups.length; i++) {
      final group = widget.groups[i];
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 65.0 : 55.0;
      final fontSize = isTouched ? AppSizes.textM : AppSizes.textS;

      final color = group.groupType < _groupColors.length
          ? _groupColors[group.groupType]
          : _groupColors.last;

      sections.add(
        PieChartSectionData(
          color: color,
          value: group.percentage,
          title: '${group.percentage.toStringAsFixed(1)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [
              Shadow(color: Colors.black26, blurRadius: 2),
            ],
          ),
        ),
      );
    }

    return sections;
  }

  /// Lấy tất cả categories từ tất cả groups và nhóm theo category
  List<_CategoryData> _getAllCategories() {
    final Map<String, _CategoryData> categoryMap = {};
    
    for (final group in widget.groups) {
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline_rounded,
            size: 80,
            color: AppColors.light.neutralTextDisable,
          ),
          const SizedBox(height: AppSizes.m),
          Text(
            'Chưa có dữ liệu thống kê',
            style: TextStyle(
              fontSize: AppSizes.textM,
              color: AppColors.light.neutralTextSecondary,
            ),
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
