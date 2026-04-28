import 'package:zenit/features/goals/models/goal_model.dart';

final goalWidgetOngoing = GoalModel(
  id: 'g1',
  name: 'Buy laptop',
  targetAmount: 20000000,
  currentAmount: 5000000,
  backgroundColor: '#D2E4FF',
  icon: 'laptop',
  createdAt: DateTime.utc(2026, 4, 1),
  dueDate: DateTime.utc(2026, 8, 1),
  note: 'saving plan',
  status: GoalStatus.ongoing,
);

final goalWidgetPaused = GoalModel(
  id: 'g2',
  name: 'New phone',
  targetAmount: 10000000,
  currentAmount: 1000000,
  backgroundColor: '#D2E4FF',
  icon: 'smartphone',
  createdAt: DateTime.utc(2026, 4, 1),
  dueDate: DateTime.utc(2026, 9, 1),
  note: '',
  status: GoalStatus.paused,
);