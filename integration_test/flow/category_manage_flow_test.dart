import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/core/layout/navigation_bar.dart';
import 'package:zenit/features/setting_childs/category_manage/forms/add_edit_category_form.dart';
import 'package:zenit/main.dart';

import '../helpers/integration_test_harness.dart';
import '../helpers/mock_api_rules.dart';
import '../helpers/test_http_adapter.dart';
import '../helpers/test_jwt.dart';

void main() {
  testWidgets('add category flow from settings screen', (tester) async {
    final accessToken = buildJwtToken(expiresInSeconds: 3600);
    bool categoryCreated = false;

    final rules = <StaticHttpRule>[
      ...buildAuthenticatedApiRules(),
      StaticHttpRule(
        matches: (options) {
          if (options.method.toUpperCase() != 'POST' ||
              options.path != ApiEndpoints.createCategory) {
            return false;
          }

          final requestData = options.data;
          if (requestData is Map) {
            categoryCreated = requestData['name'] == 'Groceries Plus';
          }
          return true;
        },
        statusCode: 201,
        data: <String, dynamic>{
          'id': 'cat-created-1',
          'name': 'Groceries Plus',
          'icon': 'shopping_cart_rounded',
          'color': '#FFFFFF',
          'backgroundColor': '#FFB74D',
          'groupType': 0,
          'expenseLimit': 0,
          'expenseAlertThreshold': 0,
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

    await tester.tap(
      find.descendant(
        of: find.byType(AppNavigationBar),
        matching: find.text('Settings'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Category management'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Thêm').first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(AddCategoryForm), findsOneWidget);

    final formTextFields = find.descendant(
      of: find.byType(AddCategoryForm),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(formTextFields.first, 'Groceries Plus');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(
      find.descendant(
        of: find.byType(AddCategoryForm),
        matching: find.byIcon(Symbols.shopping_cart_rounded),
      ).first,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Symbols.check_rounded).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(categoryCreated, isTrue);
    expect(find.text('Groceries Plus'), findsWidgets);
  });
}
