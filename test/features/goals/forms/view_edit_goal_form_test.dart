import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/goals/forms/add_edit_goal_form.dart';
import 'package:zenit/features/goals/forms/view_edit_goal_form.dart';
import 'package:zenit/l10n/app_localizations.dart';

import '../../../fixtures/features/goals/goal_widget_fixtures.dart';

Widget _buildApp(Widget child) {
  return MaterialApp(
    theme: lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

void main() {
  testWidgets('ViewEditGoalForm shows details and saves edits', (tester) async {
    final controller = ViewEditGoalFormController();
    GoalFormData? submittedData;
    var submitCount = 0;

    await tester.pumpWidget(
      _buildApp(
        ViewEditGoalForm(
          initialGoal: goalWidgetOngoing,
          controller: controller,
          onSubmit: (data) async {
            submittedData = data;
            submitCount += 1;
            return true;
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Buy laptop'), findsOneWidget);
    expect(find.text('Ongoing'), findsOneWidget);
    expect(find.text('saving plan'), findsOneWidget);

    await controller.startEditing();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(TextFormField), findsNWidgets(4));

    await tester.enterText(find.byType(TextFormField).at(0), 'Buy laptop pro');
    await tester.enterText(find.byType(TextFormField).at(1), '25000000');
    await tester.enterText(find.byType(TextFormField).at(2), '7000000');
    await tester.enterText(
      find.byType(TextFormField).at(3),
      'updated saving plan',
    );

    await controller.saveChanges();
  await tester.pump(const Duration(milliseconds: 300));

    expect(submitCount, 1);
    expect(submittedData?.name, 'Buy laptop pro');
    expect(submittedData?.targetAmount, 25000000);
    expect(submittedData?.currentAmount, 7000000);
    expect(submittedData?.icon, 'flag');
    expect(submittedData?.note, 'updated saving plan');
    expect(find.text('Buy laptop pro'), findsOneWidget);
    expect(controller.isEditing.value, false);

    controller.dispose();
  });
}