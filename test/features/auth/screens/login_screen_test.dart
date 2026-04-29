import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/features/auth/screens/login.dart';
import 'package:zenit/l10n/app_localizations.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/providers/locale_provider.dart';

void main() {
  testWidgets('LoginScreen shows title and subtitle', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: MaterialApp(
          theme: lightTheme,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: LoginScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome back!'), findsWidgets);
    expect(find.text('Log in'), findsWidgets);
    // LoginForm should be present
    expect(find.byType(Form), findsWidgets);
  });
}
