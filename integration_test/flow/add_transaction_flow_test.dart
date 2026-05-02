import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/main.dart';

import '../helpers/integration_test_harness.dart';
import '../helpers/mock_api_rules.dart';
import '../helpers/test_http_adapter.dart';
import '../helpers/test_jwt.dart';

Future<void> _waitForFinder(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final endTime = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(endTime)) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 100));
  }

  expect(finder, findsOneWidget);
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

void main() {
  testWidgets('happy path adds a transaction and shows it in recent list', (
    tester,
  ) async {
    final accessToken = buildJwtToken(expiresInSeconds: 3600);

    IntegrationTestHarness.setup(
      initialStorage: IntegrationTestHarness.authenticatedStorage(
        accessToken: accessToken,
      ),
      rules: buildAuthenticatedApiRules(),
    );

    await tester.pumpWidget(const MainApp());
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-action-transaction')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('transaction-title-field')),
      'Lunch',
    );
    await tester.enterText(
      find.byKey(const ValueKey('transaction-amount-field')),
      '120000',
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('transaction-category-selector')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('category-option-cat-necessary-food')));
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('transaction-submit-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Lunch'), findsWidgets);
  });

  testWidgets('collect-later flow will creates both transaction and loan at once', (tester) async {
    final accessToken = buildJwtToken(expiresInSeconds: 3600);
    bool transactionUsedNetAmount = false;
    bool loanCreated = false;
    bool transactionCreated = false;

    final rules = <StaticHttpRule>[
      StaticHttpRule(
        matches: (options) =>
            options.method.toUpperCase() == 'GET' &&
            options.path == ApiEndpoints.transactions,
        dataBuilder: () {
          if (!transactionCreated) {
            return <String, dynamic>{
              'items': <Map<String, dynamic>>[],
              'meta': <String, dynamic>{
                'totalItems': 0,
                'pageCount': 1,
                'page': 1,
                'pageSize': 10,
              },
            };
          }

          return <String, dynamic>{
            'items': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'txn-collect-later-1',
                'title': 'Dinner paid for team',
                'note': 'Collect later from friends',
                'amount': 90000,
                'transactionDate': DateTime(
                  2026,
                  4,
                  30,
                ).toUtc().toIso8601String(),
                'categoryId': 'cat-necessary-food',
                'walletId': 'wallet-cash',
              },
            ],
            'meta': <String, dynamic>{
              'totalItems': 1,
              'pageCount': 1,
              'page': 1,
              'pageSize': 10,
            },
          };
        },
      ),
      StaticHttpRule(
        matches: (options) {
          if (options.method.toUpperCase() != 'POST' ||
              options.path != ApiEndpoints.createTransaction) {
            return false;
          }

          final requestData = options.data;
          if (requestData is Map) {
            final amount = _asInt(requestData['amount']);
            transactionUsedNetAmount = amount == 90000;
            transactionCreated = requestData['title'] == 'Dinner paid for team';
          }
          return true;
        },
        statusCode: 201,
        data: <String, dynamic>{
          'id': 'txn-collect-later-1',
          'title': 'Dinner paid for team',
          'note': 'Collect later from friends',
          'amount': 90000,
          'transactionDate': DateTime(2026, 4, 30).toUtc().toIso8601String(),
          'categoryId': 'cat-necessary-food',
          'walletId': 'wallet-cash',
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
            final amount = _asInt(requestData['amount']);
            loanCreated = amount == 30000;
          }
          return true;
        },
        statusCode: 201,
        data: <String, dynamic>{
          'id': 'loan-created-1',
          'name': 'Dinner paid for team',
          'type': 0,
          'amount': 30000,
          'date': DateTime(2026, 4, 30).toUtc().toIso8601String(),
          'dueDate': DateTime(2026, 4, 30).toUtc().toIso8601String(),
          'note': 'Collect later from friends',
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
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-action-transaction')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('transaction-title-field')),
      'Dinner paid for team',
    );
    await tester.enterText(
      find.byKey(const ValueKey('transaction-amount-field')),
      '120000',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    await _waitForFinder(
      tester,
      find.byKey(const ValueKey('transaction-loan-amount-field')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('transaction-loan-amount-field')),
      '30000',
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('transaction-category-selector')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const ValueKey('transaction-category-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('category-option-cat-necessary-food')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('transaction-submit-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(transactionUsedNetAmount, isTrue);
    expect(loanCreated, isTrue);
  });
}