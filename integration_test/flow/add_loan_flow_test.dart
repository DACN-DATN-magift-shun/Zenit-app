import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/loans/forms/add_edit_loan_form.dart';
import 'package:zenit/main.dart';

import '../helpers/integration_test_harness.dart';
import '../helpers/mock_api_rules.dart';
import '../helpers/test_http_adapter.dart';
import '../helpers/test_jwt.dart';

void main() {
  testWidgets('add loan flow from home action', (tester) async {
    final accessToken = buildJwtToken(expiresInSeconds: 3600);
    bool loanCreated = false;

    final rules = <StaticHttpRule>[
      ...buildAuthenticatedApiRules(),
      StaticHttpRule(
        matches: (options) =>
            options.method.toUpperCase() == 'GET' &&
            options.path == ApiEndpoints.loans,
        dataBuilder: () {
          if (!loanCreated) {
            return <String, dynamic>{
              'loans': <Map<String, dynamic>>[],
            };
          }

          return <String, dynamic>{
            'loans': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'loan-created-1',
                'name': 'Coworker Lunch Loan',
                'type': 0,
                'amount': 250000,
                'date': DateTime(2026, 4, 30).toUtc().toIso8601String(),
                'dueDate': DateTime(2026, 5, 5).toUtc().toIso8601String(),
                'note': 'Will collect next week',
              },
            ],
          };
        },
      ),
      StaticHttpRule(
        matches: (options) {
          if (options.method.toUpperCase() != 'POST' ||
              options.path != ApiEndpoints.createLoan) {
            return false;
          }

          final requestData = options.data;
          if (requestData is Map) {
            loanCreated =
                requestData['name'] == 'Coworker Lunch Loan' &&
                requestData['type'] == 0 &&
                requestData['amount'] == 250000;
          }
          return true;
        },
        statusCode: 201,
        data: <String, dynamic>{
          'id': 'loan-created-1',
          'name': 'Coworker Lunch Loan',
          'type': 0,
          'amount': 250000,
          'date': DateTime(2026, 4, 30).toUtc().toIso8601String(),
          'dueDate': DateTime(2026, 5, 5).toUtc().toIso8601String(),
          'note': 'Will collect next week',
        },
      ),
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

    await tester.tap(find.byKey(const ValueKey('home-action-loans')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Loans and Debts'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(AddEditLoanForm), findsOneWidget);

    final formFields = find.descendant(
      of: find.byType(AddEditLoanForm),
      matching: find.byType(TextFormField),
    );

    await tester.enterText(formFields.at(0), 'Coworker Lunch Loan');
    await tester.enterText(formFields.at(1), '250000');
    await tester.enterText(formFields.at(2), 'Will collect next week');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Symbols.check_rounded).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(loanCreated, isTrue);
    expect(find.text('Coworker Lunch Loan'), findsWidgets);
  });
}
