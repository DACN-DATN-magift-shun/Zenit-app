/// System Flow Integration Tests for Zenit App
///
/// File: system_flow_4_test.dart
/// Purpose: Test add loan feature
///
/// Test Case:
/// system flow add-loan
///   - Đăng nhập
///   - Điều hướng đến trang Loans
///   - Tạo loan mới (vay hoặc cho vay)
///   - Nhập số tiền, ngày, ngày đến hạn
///   - Xác minh loan được tạo thành công
///   - Đăng xuất

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/layout/navigation_bar.dart';
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

void main() {
  testWidgets('system flow add-loan', (tester) async {
    final harness = IntegrationTestHarness.setup(
      initialStorage: SystemFlowConfig.initialStorage(),
      useIntegrationTestBinding: true,
      installHttpAdapter: false,
    );

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

    expect(find.byType(AppNavigationBar), findsOneWidget);

    // --- Navigate to Loans ---
    await tester.tap(
      find.descendant(
        of: find.byType(AppNavigationBar),
        matching: find.text('Loans'),
      ),
    );
    await tester.pumpAndSettle();

    // --- Tap add loan button ---
    final addLoanButton = find.byIcon(Icons.add_rounded);
    if (addLoanButton.evaluate().isNotEmpty) {
      await tester.tap(addLoanButton.first);
      await tester.pumpAndSettle();
    }

    // --- Fill loan form ---
    final formFields = find.byType(TextFormField);
    const loanName = 'Vay tiền bạn';
    const loanAmount = '5000000';

    if (formFields.evaluate().length >= 2) {
      await tester.enterText(formFields.at(0), loanName);
      await tester.enterText(formFields.at(1), loanAmount);
      await tester.pumpAndSettle();
    }

    // --- Select loan type (Borrow or Lend) ---
    final segmentedButtons = find.byType(SegmentedButton);
    if (segmentedButtons.evaluate().isNotEmpty) {
      final buttons = find.descendant(
        of: segmentedButtons.first,
        matching: find.byType(InkWell),
      );
      if (buttons.evaluate().length > 1) {
        await tester.tap(buttons.at(1)); // Select "Cho vay"
        await tester.pumpAndSettle();
      }
    }

    // --- Submit loan form ---
    final submitButton = find.byType(ElevatedButton);
    if (submitButton.evaluate().isNotEmpty) {
      await tester.tap(submitButton.first);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }

    // --- Verify loan appears in list ---
    await _waitForFinder(tester, find.text(loanName));

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
