import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/goals/widgets/goal_list_item.dart';

import '../../../fixtures/features/goals/goal_widget_fixtures.dart';

void main() {
  group('Goal widgets', () {
    testWidgets('GoalListItem renders ongoing goal details', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          locale: const Locale('en'),
          home: Scaffold(
            body: GoalListItem(
              goal: goalWidgetOngoing,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Buy laptop'), findsOneWidget);
      expect(find.text('Ongoing'), findsOneWidget);
      expect(find.textContaining('Current:'), findsOneWidget);
      expect(find.textContaining('Target:'), findsOneWidget);
      expect(find.textContaining('Due date:'), findsOneWidget);
      expect(find.text('saving plan'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
    });

    testWidgets('GoalListItem delete action invokes callback', (tester) async {
      var deleteCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          locale: const Locale('en'),
          home: Scaffold(
            body: GoalListItem(
              goal: goalWidgetPaused,
              onTap: () {},
              onDelete: () => deleteCount += 1,
            ),
          ),
        ),
      );

      await tester.drag(find.byType(Slidable), const Offset(-400, 0));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Delete'));
      await tester.pump();

      expect(deleteCount, 1);
    });
  });
}