import 'package:zenit/features/goals/models/goal_model.dart';

final goalsProviderMockGoals = <GoalModel>[
  GoalModel(
    id: 'g-ongoing',
    name: 'Emergency fund',
    targetAmount: 1000,
    currentAmount: 250,
    backgroundColor: '#D2E4FF',
    icon: 'savings',
    createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
    dueDate: DateTime.parse('2026-12-31T00:00:00Z'),
    status: GoalStatus.ongoing,
  ),
  GoalModel(
    id: 'g-completed',
    name: 'Buy bike',
    targetAmount: 500,
    currentAmount: 500,
    backgroundColor: '#D2E4FF',
    icon: 'directions_car',
    createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
    dueDate: DateTime.parse('2026-06-30T00:00:00Z'),
    status: GoalStatus.completed,
  ),
];

final goalsProviderUpdatedList = <GoalModel>[
  ...goalsProviderMockGoals,
  GoalModel(
    id: 'g-new',
    name: 'Trip',
    targetAmount: 800,
    currentAmount: 100,
    backgroundColor: '#D2E4FF',
    icon: 'flight',
    createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
    dueDate: DateTime.parse('2026-11-30T00:00:00Z'),
    status: GoalStatus.ongoing,
  ),
];
