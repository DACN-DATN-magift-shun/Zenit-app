import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/layout/navigation_bar.dart';
import 'package:zenit/main.dart';

import '../helpers/integration_test_harness.dart';
import '../helpers/mock_api_rules.dart';
import '../helpers/test_jwt.dart';

void main() {
  Finder _navLabel(String label) {
    return find.descendant(
      of: find.byType(AppNavigationBar),
      matching: find.text(label),
    );
  }

  testWidgets('bottom navigation changes selected tab index', (tester) async {
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

    AppNavigationBar navBar = tester.widget<AppNavigationBar>(
      find.byType(AppNavigationBar),
    );
    expect(navBar.selectedIndex, 0);

    await tester.tap(_navLabel('Statistics'));
    await tester.pumpAndSettle();

    navBar = tester.widget<AppNavigationBar>(find.byType(AppNavigationBar));
    expect(navBar.selectedIndex, 1);

    await tester.tap(_navLabel('Settings'));
    await tester.pumpAndSettle();

    navBar = tester.widget<AppNavigationBar>(find.byType(AppNavigationBar));
    expect(navBar.selectedIndex, 3);
  });
}
