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
///   - Xác minh giao dịch được tạo thành công
///   - Xem giao dịch trong lịch sử
///   - Đăng xuất

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/core/layout/navigation_bar.dart';
import 'package:zenit/data/local/storage_service.dart';
import 'package:zenit/data/network/api_client.dart';
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
  await tester.tap(find.byType(ElevatedButton).first);
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

  final categoryFinder = find.text(categoryName);
  await _waitForFinder(tester, categoryFinder);
  await tester.tap(categoryFinder.first);
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
  await tester.tap(checkbox.last);
  await tester.pumpAndSettle();
}

Future<void> _fillLoanAmount(
  WidgetTester tester,
  String loanAmount,
) async {
  // After enabling "collect later", there should be a new TextFormField for loan amount
  final allFields = find.byType(TextFormField);
  // The loan amount field is typically the 4th field after amount, title, note
  if (allFields.evaluate().length >= 4) {
    await tester.enterText(allFields.at(3), loanAmount);
    await tester.pumpAndSettle();
  }
}

Future<void> _selectLoanDueDate(WidgetTester tester) async {
  // Tap on the loan due date selector (InkWell)
  final dueeDateButtons = find.byIcon(Icons.edit_calendar_rounded);
  if (dueeDateButtons.evaluate().isNotEmpty) {
    await tester.tap(dueeDateButtons.first);
    await tester.pumpAndSettle();
    
    // Select a date (e.g., 10 days from now)
    final okButton = find.text('OK');
    if (okButton.evaluate().isNotEmpty) {
      await tester.tap(okButton.first);
      await tester.pumpAndSettle();
    }
  }
}

Future<String?> _findCreatedTransactionId({
  required String accessToken,
  required String transactionTitle,
  required String transactionAmount,
  required String transactionNote,
}) async {
  final response = await ApiClient().get<dynamic>(
    ApiEndpoints.transactions,
    options: Options(
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    ),
  );

  final data = response.data;
  if (data is! Map) {
    return null;
  }

  final items = data['items'];
  if (items is! List) {
    return null;
  }

  for (final item in items) {
    if (item is! Map) {
      continue;
    }

    final title = item['title']?.toString();
    final amount = item['amount']?.toString();
    final note = item['note']?.toString();

    if (title == transactionTitle &&
        amount == transactionAmount &&
        note == transactionNote) {
      return item['id']?.toString();
    }
  }

  return null;
}

Future<void> _cleanupTransactionIfPossible({
  required String? accessToken,
  required String? transactionId,
}) async {
  if (accessToken == null || accessToken.isEmpty) {
    return;
  }

  if (transactionId == null || transactionId.isEmpty) {
    return;
  }

  try {
    await ApiClient().delete<dynamic>(
      ApiEndpoints.deleteTransactionUrl(transactionId),
      options: Options(
        headers: <String, String>{'Authorization': 'Bearer $accessToken'},
      ),
    );
  } catch (_) {
    // Best-effort cleanup only.
  }
}

void main() {
  testWidgets('system flow add-transaction-with-collect-later', (tester) async {
    final harness = IntegrationTestHarness.setup(
      initialStorage: SystemFlowConfig.initialStorage(),
      useIntegrationTestBinding: true,
      installHttpAdapter: false,
    );

    String? createdTransactionId;
    String? accessTokenForCleanup;

    addTearDown(() async {
      await _cleanupTransactionIfPossible(
        accessToken: accessTokenForCleanup,
        transactionId: createdTransactionId,
      );
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

    expect(find.byType(AppNavigationBar), findsOneWidget);

    // --- Open transaction drawer ---
    await _openTransactionDrawer(tester);

    // --- Fill transaction basic info ---
    await tester.enterText(
      find.byType(TextFormField).at(0),
      SystemFlowConfig.transactionAmount,
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      SystemFlowConfig.transactionTitle,
    );
    await tester.enterText(
      find.byType(TextFormField).at(2),
      SystemFlowConfig.transactionNote,
    );
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
    const loanAmount = '50000';
    await _fillLoanAmount(tester, loanAmount);

    // --- Select loan due date ---
    await _selectLoanDueDate(tester);

    // --- Submit transaction ---
    await tester.tap(find.byKey(const ValueKey('transaction-submit-button')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // --- Verify success ---
    expect(find.text(SystemFlowConfig.transactionSuccessMessage), findsOneWidget);

    // --- Get access token for cleanup ---
    accessTokenForCleanup = harness.storageController.readValue(
      StorageService.accessTokenKey,
    );

    // --- Find created transaction ---
    createdTransactionId = await _findCreatedTransactionId(
      accessToken: accessTokenForCleanup ?? '',
      transactionTitle: SystemFlowConfig.transactionTitle,
      transactionAmount: SystemFlowConfig.transactionAmount,
      transactionNote: SystemFlowConfig.transactionNote,
    );

    // --- Navigate to History ---
    await tester.tap(
      find.descendant(
        of: find.byType(AppNavigationBar),
        matching: find.text('History'),
      ),
    );
    await tester.pumpAndSettle();

    // --- Verify transaction appears in history ---
    await _waitForFinder(tester, find.text(SystemFlowConfig.transactionTitle));

    // --- Logout ---
    await tester.tap(
      find.descendant(
        of: find.byType(AppNavigationBar),
        matching: find.text('Settings'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Logout').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout').last);
    await tester.pumpAndSettle();

    // --- Verify logout ---
    await _waitForFinder(tester, find.text(SystemFlowConfig.logoutSuccessMessage));
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
