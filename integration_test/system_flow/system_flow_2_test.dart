/// System Flow Integration Tests for Zenit App
///
/// File: system_flow_2_test.dart
/// Purpose: Test add transaction with "collect later" (pay on behalf) feature
///
/// Test Case:
/// system flow add-transaction-with-collect-later
///   - Đăng nhập
///   - Tạo giao dịch với tính năng "chi hộ - thu hồi sau"
///   - Nhập số tiền chi hộ và ngày đến hạn
///   - Submit giao dịch
///   - Điều hướng sang tab History
///   - Xác minh giao dịch xuất hiện trong lịch sử
///
/// PowerShell run command:
/// Set-Location 'D:\Hoc Tap\HK251\DACN\zenit'; flutter test integration_test/system_flow/system_flow_2_test.dart --dart-define API_BASE_URL=https://zenit-api-tuir.onrender.com/ --dart-define USE_PRODUCTION=true --dart-define SYSTEM_TEST_EMAIL=tuan5@gmail.com --dart-define SYSTEM_TEST_PASSWORD='0788778027@' --dart-define TRANSACTION_TITLE='Test Transaction' --dart-define TRANSACTION_NOTE='Test note' --dart-define TRANSACTION_AMOUNT=50000 --dart-define WALLET_NAME='VCB' --dart-define CATEGORY_NAME='test'

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:material_symbols_icons/symbols.dart';
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
    if (loginFinder.evaluate().isNotEmpty ||
        navBarFinder.evaluate().isNotEmpty) {
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

Future<void> _tapNavigationTab(WidgetTester tester, String tabLabel) async {
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

Future<void> _enableCollectLater(WidgetTester tester) async {
  final checkbox = find.byType(Checkbox);
  expect(checkbox, findsWidgets);

  // Find the checkbox in the ExpansionTile header for "collect later"
  await tester.tap(checkbox.last, warnIfMissed: false);
  await tester.pumpAndSettle();
}

Future<void> _fillLoanAmount(WidgetTester tester, String loanAmount) async {
  final loanAmountField = find.byKey(
    const ValueKey('transaction-loan-amount-field'),
  );
  await _waitForFinder(tester, loanAmountField);
  await tester.enterText(loanAmountField, loanAmount);
  await tester.pumpAndSettle();
}

Future<void> _selectLoanDueDate(WidgetTester tester) async {
  final dueDateIcons = find.byIcon(Symbols.calendar_month_rounded);
  if (dueDateIcons.evaluate().isEmpty) {
    return;
  }

  await tester.tap(dueDateIcons.first, warnIfMissed: false);
  await tester.pumpAndSettle();

  final okFinder = find.text('OK');
  if (okFinder.evaluate().isNotEmpty) {
    await tester.tap(okFinder.first, warnIfMissed: false);
  } else {
    final saveFinder = find.text('Save');
    if (saveFinder.evaluate().isNotEmpty) {
      await tester.tap(saveFinder.first, warnIfMissed: false);
    }
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('system flow add-transaction-with-collect-later', (tester) async {
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

    // --- Login ---
    await _login(
      tester,
      email: SystemFlowConfig.loginEmail,
      password: SystemFlowConfig.loginPassword,
    );

    await _waitForFinder(
      tester,
      find.byKey(const ValueKey('home-action-transaction')),
    );

    // --- Open transaction drawer ---
    await _openTransactionDrawer(tester);

    // --- Fill transaction basic info ---
    await tester.enterText(
      find.byType(TextFormField).at(0),
      SystemFlowConfig.transactionAmount,
    );
    await tester.enterText(find.byType(TextFormField).at(1), transactionTitle);
    await tester.enterText(find.byType(TextFormField).at(2), transactionNote);
    await tester.pumpAndSettle();

    // --- Select wallet ---
    await _cycleWalletUntilVisible(
      tester,
      initialWalletName: SystemFlowConfig.initialWalletName,
      targetWalletName: SystemFlowConfig.targetWalletName,
    );

    // --- Select category ---
    await _selectCategoryByName(tester, SystemFlowConfig.categoryName);

    // --- Enable "collect later" feature ---
    await _enableCollectLater(tester);
    await tester.pumpAndSettle();

    // --- Fill loan amount ---
    const loanAmount = '30000';
    await _fillLoanAmount(tester, loanAmount);

    // --- Select loan due date ---
    await _selectLoanDueDate(tester);

    // --- Submit transaction ---
    await _tapSubmitTransaction(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // --- Navigate to History ---
    await _tapNavigationTab(tester, 'History');

    // --- Verify transaction appears in history ---
    await _waitForFinder(tester, find.text(transactionTitle));
    expect(find.text(transactionTitle), findsOneWidget);
  });
}
