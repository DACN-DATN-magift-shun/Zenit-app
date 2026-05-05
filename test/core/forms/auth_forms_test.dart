import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/forms/login_form.dart';
import 'package:zenit/core/forms/sign_up_form.dart';
import 'package:zenit/core/providers/locale_provider.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/l10n/app_localizations.dart';

Widget _buildApp(Widget child) {
  return ChangeNotifierProvider<LocaleProvider>(
    create: (_) => LocaleProvider(),
    child: MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  group('Auth forms', () {
    testWidgets('LoginForm submits valid credentials', (tester) async {
      String? submittedEmail;
      String? submittedPassword;

      await tester.pumpWidget(
        _buildApp(
          LoginForm(
            onSubmit: (email, password) {
              submittedEmail = email;
              submittedPassword = password;
            },
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'Passw0rd!');
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(submittedEmail, 'user@example.com');
      expect(submittedPassword, 'Passw0rd!');
    });

    testWidgets('SignUpForm submits valid information', (tester) async {
      String? submittedUsername;
      String? submittedEmail;
      String? submittedPhone;
      String? submittedAddress;
      String? submittedPassword;
      String? submittedConfirmPassword;

      await tester.pumpWidget(
        _buildApp(
          SignUpForm(
            onSubmit: (
              username,
              email,
              phone,
              address,
              password,
              confirmPassword,
            ) {
              submittedUsername = username;
              submittedEmail = email;
              submittedPhone = phone;
              submittedAddress = address;
              submittedPassword = password;
              submittedConfirmPassword = confirmPassword;
            },
          ),
        ),
      );

      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Confirm password'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'user_name');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'user@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'Passw0rd!');
      await tester.enterText(find.byType(TextFormField).at(3), 'Passw0rd!');
      await tester.enterText(find.byType(TextFormField).at(4), '0123456789');
      await tester.enterText(
        find.byType(TextFormField).at(5),
        '123 Main Street',
      );
      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(submittedUsername, 'user_name');
      expect(submittedEmail, 'user@example.com');
      expect(submittedPhone, '0123456789');
      expect(submittedAddress, '123 Main Street');
      expect(submittedPassword, 'Passw0rd!');
      expect(submittedConfirmPassword, 'Passw0rd!');
    });
  });
}