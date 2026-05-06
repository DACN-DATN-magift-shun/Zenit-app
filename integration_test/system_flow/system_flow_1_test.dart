import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:zenit/core/layout/navigation_bar.dart';
import 'package:zenit/core/widgets/button.dart';
import 'package:zenit/main.dart';

import '../helpers/integration_test_harness.dart';
import 'system_config.dart';

Future<void> _waitForFinder(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
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

Future<void> _waitForLoginOrHome(WidgetTester tester) async {
  final loginFinder = find.byType(TextFormField);
  final navBarFinder = find.byType(AppNavigationBar);
  final endTime = DateTime.now().add(const Duration(seconds: 15));

  while (DateTime.now().isBefore(endTime)) {
    if (loginFinder.evaluate().isNotEmpty || navBarFinder.evaluate().isNotEmpty) {
      await tester.pumpAndSettle();
      return;
    }

    await tester.pump(const Duration(milliseconds: 100));
  }

  await tester.pumpAndSettle();
}

Future<void> _login(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  final fields = find.byType(TextFormField);
  expect(fields, findsNWidgets(2));

  await tester.enterText(fields.at(0), email);
  await tester.enterText(fields.at(1), password);
  await tester.tap(find.byType(AppButton).first, warnIfMissed: false);
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

Future<void> _openTransactionDrawer(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('home-action-transaction')));
  await tester.pumpAndSettle();
}

Future<void> _selectCategoryByName(
  WidgetTester tester,
  String categoryName,
) async {
  await tester.tap(find.byKey(const ValueKey('transaction-category-selector')));
  await tester.pumpAndSettle();

  final categoryFinder = find.text(categoryName).last;
  await _waitForFinder(tester, categoryFinder);
  await tester.ensureVisible(categoryFinder);

  final tappableCategoryFinder = find.ancestor(
    of: categoryFinder,
    matching: find.byType(InkWell),
  );

  if (tappableCategoryFinder.evaluate().isNotEmpty) {
    await tester.tap(tappableCategoryFinder.first, warnIfMissed: false);
  } else {
    await tester.tap(categoryFinder, warnIfMissed: false);
  }

  await tester.pumpAndSettle();
}

Future<void> _tapSubmitTransaction(WidgetTester tester) async {
  final submitFinder = find.byKey(const ValueKey('transaction-submit-button'));
  await _waitForFinder(tester, submitFinder);

  final submitButton = tester.widget<IconButton>(submitFinder);
  expect(
    submitButton.onPressed,
    isNotNull,
    reason: 'Submit button is disabled. Form data is likely invalid.',
  );

  await tester.ensureVisible(submitFinder);
  await tester.tap(submitFinder, warnIfMissed: false);
}

Future<void> _tapNavigationTab(
  WidgetTester tester,
  String tabLabel,
) async {
  final tabFinder = find.widgetWithText(GButton, tabLabel);
  await _waitForFinder(tester, tabFinder);
  await tester.ensureVisible(tabFinder);
  await tester.tap(tabFinder, warnIfMissed: false);
  await tester.pumpAndSettle();
}

Future<void> _cycleWalletUntilVisible(
  WidgetTester tester, {
  required String initialWalletName,
  required String targetWalletName,
}) async {
  final initialFinder = find.text(initialWalletName);
  await _waitForFinder(tester, initialFinder);

  if (find.text(targetWalletName).evaluate().isNotEmpty) {
    return;
  }

  await tester.drag(initialFinder.first, const Offset(-240, 0));
  await tester.pumpAndSettle();

  expect(find.text(targetWalletName), findsWidgets);
}

void main() {
  testWidgets('system flow open-login-create-history', (tester) async {
    final harness = IntegrationTestHarness.setup(
      initialStorage: SystemFlowConfig.initialStorage(),
      useIntegrationTestBinding: true,
      installHttpAdapter: false,
    );

    final runTag = DateTime.now().millisecondsSinceEpoch.toString();
    final transactionTitle = '${SystemFlowConfig.transactionTitle} #$runTag';
    final transactionNote = '${SystemFlowConfig.transactionNote} #$runTag';

    addTearDown(() async {
      harness.dispose();
    });

    await tester.pumpWidget(const MainApp());
    await _waitForLoginOrHome(tester);

    await _login(
      tester,
      email: SystemFlowConfig.loginEmail,
      password: SystemFlowConfig.loginPassword,
    );

    await _openTransactionDrawer(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      SystemFlowConfig.transactionAmount,
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      transactionTitle,
    );
    await tester.enterText(
      find.byType(TextFormField).at(2),
      transactionNote,
    );
    await tester.pumpAndSettle();

    await _cycleWalletUntilVisible(
      tester,
      initialWalletName: SystemFlowConfig.initialWalletName,
      targetWalletName: SystemFlowConfig.targetWalletName,
    );

    await _selectCategoryByName(tester, SystemFlowConfig.categoryName);

    await _tapSubmitTransaction(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    await _tapNavigationTab(tester, 'History');

    await _waitForFinder(tester, find.text(transactionTitle));
    expect(find.text(transactionTitle), findsOneWidget);
  });
}