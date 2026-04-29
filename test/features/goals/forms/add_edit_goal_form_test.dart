import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/goals/forms/add_edit_goal_form.dart';
import 'package:zenit/features/goals/models/goal_model.dart';
import 'package:zenit/l10n/app_localizations.dart';

Widget _buildApp(Widget child) {
  return MaterialApp(
    theme: lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('AddEditGoalForm submits valid data', (tester) async {
    final controller = AddEditGoalFormController();
    GoalFormData? submittedData;

    await tester.pumpWidget(
      _buildApp(
        AddEditGoalForm(
          controller: controller,
          onSubmit: (data) async {
            submittedData = data;
          },
        ),
      ),
    );

    expect(find.text('Goal name'), findsOneWidget);
    expect(find.text('Target amount'), findsOneWidget);
    expect(find.text('Current amount'), findsOneWidget);
    expect(find.text('Due date'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Buy laptop');
    await tester.enterText(find.byType(TextFormField).at(1), '20000000');
    await tester.enterText(find.byType(TextFormField).at(2), '5000000');
    await tester.enterText(find.byType(TextFormField).at(3), 'saving plan');

    await controller.submit();
    await tester.pumpAndSettle();

    expect(submittedData?.name, 'Buy laptop');
    expect(submittedData?.targetAmount, 20000000);
    expect(submittedData?.currentAmount, 5000000);
    expect(submittedData?.icon, 'flag');
    expect(submittedData?.backgroundColor, '#8CCAF7');
    expect(submittedData?.status, GoalStatus.ongoing);
    expect(submittedData?.note, 'saving plan');
  });
}