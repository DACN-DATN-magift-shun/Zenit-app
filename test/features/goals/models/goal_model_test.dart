import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/features/goals/models/goal_model.dart';
import '../../../mocks/features/goals/goal_model_mock_data.dart';
import '../../../mocks/json_source_mock.dart';

void main() {
  group('GoalModel', () {
    test('fromJson parses values and computes progress', () {
      final source = MockJsonSource();
      when(() => source.value).thenReturn(goalFromJsonMockData);

      final model = GoalModel.fromJson(source.value);

      expect(model.id, 'g1');
      expect(model.status, GoalStatus.completed);
      expect(model.progress, 0.25);
    });

    test('toCreateJson uses UTC ISO and status value', () {
      final model = GoalModel(
        id: 'g1',
        name: 'Goal',
        targetAmount: 100,
        currentAmount: 20,
        backgroundColor: '#FFFFFF',
        icon: 'flag',
        createdAt: DateTime.parse('2026-04-01T00:00:00Z'),
        dueDate: DateTime.parse('2026-05-01T00:00:00Z'),
        status: GoalStatus.paused,
      );

      final json = model.toCreateJson();

      expect(json['name'], 'Goal');
      expect(json['status'], 2);
      expect((json['createdAt'] as String).endsWith('Z'), true);
    });

    test('copyWith overrides selected fields only', () {
      final model = GoalModel(
        id: 'g1',
        name: 'Old',
        targetAmount: 100,
        currentAmount: 10,
        backgroundColor: '#FFFFFF',
        icon: 'flag',
        createdAt: DateTime.parse('2026-04-01T00:00:00Z'),
        dueDate: DateTime.parse('2026-05-01T00:00:00Z'),
      );

      final copied = model.copyWith(name: 'New', currentAmount: 50);

      expect(copied.name, 'New');
      expect(copied.currentAmount, 50);
      expect(copied.targetAmount, 100);
    });
  });
}
