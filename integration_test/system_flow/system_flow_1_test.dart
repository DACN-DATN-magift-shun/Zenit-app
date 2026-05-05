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
  testWidgets('system flow open-login-create-history-logout', (tester) async {
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

    await _login(
      tester,
      email: SystemFlowConfig.loginEmail,
      password: SystemFlowConfig.loginPassword,
    );

    expect(find.byType(AppNavigationBar), findsOneWidget);

    await _openTransactionDrawer(tester);

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

    await _cycleWalletUntilVisible(
      tester,
      initialWalletName: SystemFlowConfig.initialWalletName,
      targetWalletName: SystemFlowConfig.targetWalletName,
    );

    await _selectCategoryByName(tester, SystemFlowConfig.categoryName);

    await tester.tap(find.byKey(const ValueKey('transaction-submit-button')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text(SystemFlowConfig.transactionSuccessMessage), findsOneWidget);

    accessTokenForCleanup = harness.storageController.readValue(
      StorageService.accessTokenKey,
    );

    createdTransactionId = await _findCreatedTransactionId(
      accessToken: accessTokenForCleanup ?? '',
      transactionTitle: SystemFlowConfig.transactionTitle,
      transactionAmount: SystemFlowConfig.transactionAmount,
      transactionNote: SystemFlowConfig.transactionNote,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(AppNavigationBar),
        matching: find.text('History'),
      ),
    );
    await tester.pumpAndSettle();

    await _waitForFinder(tester, find.text(SystemFlowConfig.transactionTitle));

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

    await _waitForFinder(tester, find.text(SystemFlowConfig.logoutSuccessMessage));
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}