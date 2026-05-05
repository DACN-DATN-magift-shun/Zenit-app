/// System Flow Integration Tests for Zenit App
///
/// File: system_flow_3_test.dart
/// Purpose: Test add goal feature
///
/// Test Case:
/// system flow add-goal
///   - Đăng nhập
///   - Điều hướng đến trang Goals
///   - Tạo goal mới với tên, số tiền mục tiêu, ngày đến hạn
///   - Chọn icon và màu sắc
///   - Xác minh goal được tạo thành công
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
  testWidgets('system flow add-goal', (tester) async {
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

    // --- Navigate to Goals ---
    await tester.tap(
      find.descendant(
        of: find.byType(AppNavigationBar),
        matching: find.text('Goals'),
      ),
    );
    await tester.pumpAndSettle();

    // --- Tap add goal button ---
    final addGoalButton = find.byIcon(Icons.add_rounded);
    if (addGoalButton.evaluate().isNotEmpty) {
      await tester.tap(addGoalButton.first);
      await tester.pumpAndSettle();
    }

    // --- Fill goal form ---
    final formFields = find.byType(TextFormField);
    const goalName = 'Mua Laptop';
    const goalTargetAmount = '25000000';

    if (formFields.evaluate().length >= 2) {
      await tester.enterText(formFields.at(0), goalName);
      await tester.enterText(formFields.at(1), goalTargetAmount);
      await tester.pumpAndSettle();
    }

    // --- Select goal icon/color ---
    final colorButtons = find.byType(Container);
    if (colorButtons.evaluate().isNotEmpty) {
      // Tap on first color/icon option
      await tester.tap(colorButtons.first);
      await tester.pumpAndSettle();
    }

    // --- Submit goal form ---
    final submitButton = find.byType(ElevatedButton);
    if (submitButton.evaluate().isNotEmpty) {
      await tester.tap(submitButton.first);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }

    // --- Verify goal appears in list ---
    await _waitForFinder(tester, find.text(goalName));

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
