import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/features/statistics/models/statistics_model.dart';
import '../../../mocks/features/statistics/statistics_model_mock_data.dart';
import '../../../mocks/json_source_mock.dart';

void main() {
  group('Statistics models', () {
    test('StatisticsResponseModel.fromJson parses groupStatistics schema', () {
      final source = MockJsonSource();
      when(() => source.value).thenReturn(statisticsResponseMockData);

      final response = StatisticsResponseModel.fromJson(source.value);

      expect(response.items.length, 1);
      expect(response.items.first.groupName, 'Necessary');
      expect(response.items.first.categories.first.name, 'Food');
      expect(response.incomeExpenseStatistics.totalIncome, 500);
    });

    test('group getters and totalAmount work correctly', () {
      final model = StatisticsResponseModel(
        items: [
          StatisticsGroupModel(
            totalAmount: 200,
            percentage: 20,
            percentageChange: 0,
            groupType: 1,
            categories: const [],
          ),
          StatisticsGroupModel(
            totalAmount: 300,
            percentage: 30,
            percentageChange: 0,
            groupType: 3,
            categories: const [],
          ),
        ],
        incomeExpenseStatistics: const IncomeExpenseStatisticsModel(
          totalIncome: 0,
          totalExpense: 0,
          incomePercentageChange: 0,
          expensePercentageChange: 0,
        ),
      );

      expect(model.savingsGroup?.groupType, 1);
      expect(model.entertainmentGroup?.groupType, 3);
      expect(model.necessaryGroup, null);
      expect(model.totalAmount, 500);
    });
  });
}
