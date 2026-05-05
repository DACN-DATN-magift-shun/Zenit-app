import 'package:zenit/features/statistics/models/statistics_model.dart';

final statisticsWidgetNecessaryGroup = StatisticsGroupModel(
  totalAmount: 1200,
  percentage: 60,
  percentageChange: 12,
  groupType: 0,
  categories: const <StatisticsCategoryModel>[],
);

final statisticsWidgetSavingsGroup = StatisticsGroupModel(
  totalAmount: 800,
  percentage: 40,
  percentageChange: -5,
  groupType: 1,
  categories: const <StatisticsCategoryModel>[],
);

List<StatisticsGroupModel> buildStatisticsWidgetGroups() {
  return <StatisticsGroupModel>[
    statisticsWidgetNecessaryGroup,
    statisticsWidgetSavingsGroup,
  ];
}