import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/goals/forms/add_edit_goal_form.dart';
import 'package:zenit/main.dart';

import '../helpers/integration_test_harness.dart';
import '../helpers/mock_api_rules.dart';
import '../helpers/test_http_adapter.dart';
import '../helpers/test_jwt.dart';

void main() {
  testWidgets('add goal flow from home action', (tester) async {
    final accessToken = buildJwtToken(expiresInSeconds: 3600);
    bool goalCreated = false;

    final rules = <StaticHttpRule>[
      StaticHttpRule(
        matches: (options) =>
            options.method.toUpperCase() == 'GET' &&
            options.path == ApiEndpoints.goals,
        dataBuilder: () {
          if (!goalCreated) {
            return <String, dynamic>{
              'goals': <Map<String, dynamic>>[],
            };
          }

          return <String, dynamic>{
            'goals': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'goal-created-1',
                'name': 'Emergency Fund 2026',
                'targetAmount': 10000000,
                'currentAmount': 1200000,
                'backgroundColor': '#8CCAF7',
                'icon': 'flag',
                'createdAt': DateTime(2026, 4, 30).toUtc().toIso8601String(),
                'dueDate': DateTime(2026, 12, 31).toUtc().toIso8601String(),
                'note': 'Save monthly for emergencies',
                'status': 0,
              },
            ],
          };
        },
      ),
      StaticHttpRule(
        matches: (options) {
          if (options.method.toUpperCase() != 'POST' ||
              options.path != ApiEndpoints.createGoal) {
            return false;
          }

          final requestData = options.data;
          if (requestData is Map) {
            goalCreated =
                requestData['name'] == 'Emergency Fund 2026' &&
                requestData['targetAmount'] == 10000000 &&
                requestData['currentAmount'] == 1200000;
          }
          return true;
        },
        statusCode: 201,
        data: <String, dynamic>{
          'id': 'goal-created-1',
          'name': 'Emergency Fund 2026',
          'targetAmount': 10000000,
          'currentAmount': 1200000,
          'backgroundColor': '#8CCAF7',
          'icon': 'flag',
          'createdAt': DateTime(2026, 4, 30).toUtc().toIso8601String(),
          'dueDate': DateTime(2026, 12, 31).toUtc().toIso8601String(),
          'note': 'Save monthly for emergencies',
          'status': 0,
        },
      ),
      ...buildAuthenticatedApiRules(),
    ];

    IntegrationTestHarness.setup(
      initialStorage: IntegrationTestHarness.authenticatedStorage(
        accessToken: accessToken,
      ),
      rules: rules,
    );

    await tester.pumpWidget(const MainApp());
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-action-goals')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('home-action-goals')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Goals management'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(AddEditGoalForm), findsOneWidget);

    final formFields = find.descendant(
      of: find.byType(AddEditGoalForm),
      matching: find.byType(TextFormField),
    );

    await tester.enterText(formFields.at(0), 'Emergency Fund 2026');
    await tester.enterText(formFields.at(1), '10000000');
    await tester.enterText(formFields.at(2), '1200000');
    await tester.enterText(formFields.at(3), 'Save monthly for emergencies');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Symbols.check_rounded).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(goalCreated, isTrue);
    expect(find.text('Emergency Fund 2026'), findsWidgets);
  });
}