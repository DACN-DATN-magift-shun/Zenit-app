import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/features/auth/screens/signup.dart';
import 'package:zenit/l10n/app_localizations.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/providers/locale_provider.dart';

void main() {
  testWidgets('SignupScreen shows title and subtitle', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: MaterialApp(
          theme: lightTheme,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: SizedBox(width: 400, child: SignupScreen()),
            ),
          ),
        ),
      ),
    );

    // let layout settle (avoid pumpAndSettle due to animations)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Create account'), findsWidgets);
    expect(find.text('Sign up'), findsWidgets);
    // SignUpForm should be present (at least one)
    expect(find.byType(Form), findsWidgets);
  });
}
