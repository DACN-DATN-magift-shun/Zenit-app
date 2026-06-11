import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/features/goals/models/goal_model.dart';
import 'package:zenit/features/goals/providers/goals_provider.dart';
import 'package:zenit/features/goals/services/goals_service.dart';

import '../../../mocks/features/goals/goals_provider_mock_data.dart';

class MockGoalsService extends Mock implements GoalsService {}

void main() {
  late MockGoalsService goalsService;
  late GoalsProvider provider;

  setUp(() {
    goalsService = MockGoalsService();
    provider = GoalsProvider(goalsService: goalsService);
  });

  group('GoalsProvider', () {
    test('loadGoals success updates state and computed metrics', () async {
      when(
        () => goalsService.getGoals(search: null, pageSize: 100),
      ).thenAnswer((_) async => goalsProviderMockGoals);

      await provider.loadGoals();

      expect(provider.errorMessage, isNull);
      expect(provider.goals.length, 2);
      expect(provider.totalTargetAmount, 1000);
      expect(provider.totalCurrentAmount, 250);
      expect(provider.amountProgress, 0.25);
      expect(provider.completedGoalsCount, 1);
    });

    test('loadGoals failure stores error message', () async {
      when(
        () => goalsService.getGoals(search: null, pageSize: 100),
      ).thenThrow(Exception('boom'));

      await provider.loadGoals();

      expect(provider.errorMessage, contains('boom'));
      expect(provider.isLoading, false);
    });

    test('setStatusFilter filters goals by status', () async {
      when(
        () => goalsService.getGoals(search: null, pageSize: 100),
      ).thenAnswer((_) async => goalsProviderMockGoals);

      await provider.loadGoals();
      await provider.setStatusFilter(GoalStatus.completed);

      expect(provider.goals.length, 1);
      expect(provider.goals.first.status, GoalStatus.completed);
    });

    test('addGoal success refreshes goals list', () async {
      final dueDate = DateTime.parse('2026-11-30T00:00:00Z');

      when(
        () => goalsService.createGoal(
          name: 'Trip',
          targetAmount: 800,
          currentAmount: 100,
          backgroundColor: '#D2E4FF',
          icon: 'flight',
          dueDate: dueDate,
          note: '',
          status: GoalStatus.ongoing,
        ),
      ).thenAnswer((_) async => goalsProviderUpdatedList.last);

      when(
        () => goalsService.getGoals(search: null, pageSize: 100),
      ).thenAnswer((_) async => goalsProviderUpdatedList);

      final result = await provider.addGoal(
        name: 'Trip',
        targetAmount: 800,
        currentAmount: 100,
        backgroundColor: '#D2E4FF',
        icon: 'flight',
        dueDate: dueDate,
        note: '',
        status: GoalStatus.ongoing,
      );

      expect(result, true);
      expect(provider.goals.length, 3);
      verify(() => goalsService.createGoal(
            name: 'Trip',
            targetAmount: 800,
            currentAmount: 100,
            backgroundColor: '#D2E4FF',
            icon: 'flight',
            dueDate: dueDate,
            note: '',
            status: GoalStatus.ongoing,
          )).called(1);
    });
  });
}
