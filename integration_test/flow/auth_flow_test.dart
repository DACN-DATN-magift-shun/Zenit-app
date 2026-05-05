import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/core/layout/navigation_bar.dart';
import 'package:zenit/features/auth/screens/login.dart';
import 'package:zenit/main.dart';

import '../helpers/integration_test_harness.dart';
import '../helpers/mock_api_rules.dart';
import '../helpers/test_http_adapter.dart';
import '../helpers/test_jwt.dart';

void main() {
  testWidgets('opening splash routes unauthenticated users to login', (
    tester,
  ) async {
    IntegrationTestHarness.setup(
      initialStorage: IntegrationTestHarness.unauthenticatedStorage(),
      rules: const <StaticHttpRule>[],
    );

    await tester.pumpWidget(const MainApp());

    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('opening splash routes authenticated users to home shell', (
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

    expect(find.byType(AppNavigationBar), findsOneWidget);
  });

  testWidgets('login with invalid credentials stays on login screen', (
    tester,
  ) async {
    IntegrationTestHarness.setup(
      initialStorage: IntegrationTestHarness.unauthenticatedStorage(),
      rules: <StaticHttpRule>[
        StaticHttpRule(
          matches: (options) =>
              options.method.toUpperCase() == 'POST' &&
              options.path == ApiEndpoints.login,
          statusCode: 401,
          data: <String, dynamic>{
            'message': 'WRONG_PASSWORD',
          },
        ),
      ],
    );

    await tester.pumpWidget(const MainApp());

    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(2));

    await tester.enterText(textFields.at(0), 'tester@example.com');
    await tester.enterText(textFields.at(1), 'Passw0rd!');

    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('login success routes user to home shell', (tester) async {
    IntegrationTestHarness.setup(
      initialStorage: IntegrationTestHarness.unauthenticatedStorage(),
      rules: <StaticHttpRule>[
        StaticHttpRule(
          matches: (options) =>
              options.method.toUpperCase() == 'POST' &&
              options.path == ApiEndpoints.login,
          statusCode: 200,
          data: <String, dynamic>{
            'accessToken': buildJwtToken(expiresInSeconds: 3600),
            'refreshToken': 'refresh-token-test',
          },
        ),
        ...buildAuthenticatedApiRules(),
      ],
    );

    await tester.pumpWidget(const MainApp());

    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(2));

    await tester.enterText(textFields.at(0), 'tester@example.com');
    await tester.enterText(textFields.at(1), 'Passw0rd!');

    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byType(AppNavigationBar), findsOneWidget);
  });
}
