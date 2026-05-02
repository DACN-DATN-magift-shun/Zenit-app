import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import 'package:zenit/features/auth/screens/signup.dart';
import 'package:zenit/core/forms/sign_up_form.dart';
import 'package:zenit/l10n/app_localizations.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/providers/locale_provider.dart';
import 'package:zenit/features/auth/services/account_service.dart';
import 'package:zenit/core/services/auth_service.dart';

import '../../../mocks/network/api_client_mocks.dart';
import 'package:zenit/core/widgets/button.dart';

class MockAccountService extends Mock implements AccountService {}
class MockAuthService extends Mock implements AuthService {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  testWidgets('SignupScreen successful signup calls saveSignupData', (tester) async {
    final mockAccount = MockAccountService();
    final mockAuth = MockAuthService();

    when(() => mockAccount.register(
          username: any(named: 'username'),
          email: any(named: 'email'),
          phone: any(named: 'phone'),
          address: any(named: 'address'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => buildResponse(statusCode: 201, data: {'id': 'u1'}));

    when(() => mockAuth.saveSignupData(userId: any(named: 'userId'))).thenAnswer((_) async {});

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: MaterialApp(
          theme: lightTheme,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: Center(child: SizedBox(width: 400, child: SignupScreen(accountService: mockAccount, authService: mockAuth)))),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Invoke the form submission callback directly to avoid layout/validation flakiness.
    final signUpForm = tester.widget<SignUpForm>(find.byType(SignUpForm));
    signUpForm.onSubmit(
      'username',
      'user@example.com',
      '0123456789',
      'Some address',
      'P@ssw0rd123!',
      'P@ssw0rd123!',
    );

    await tester.pumpAndSettle();

    verify(() => mockAuth.saveSignupData(userId: 'u1')).called(1);
  });

  testWidgets('SignupScreen handles register DioException', (tester) async {
    final mockAccount = MockAccountService();
    final mockAuth = MockAuthService();

    when(() => mockAccount.register(
          username: any(named: 'username'),
          email: any(named: 'email'),
          phone: any(named: 'phone'),
          address: any(named: 'address'),
          password: any(named: 'password'),
        )).thenThrow(DioException(requestOptions: RequestOptions(path: ''), type: DioExceptionType.connectionTimeout));

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: MaterialApp(
          theme: lightTheme,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: Center(child: SizedBox(width: 400, child: SignupScreen(accountService: mockAccount, authService: mockAuth)))),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final signUpForm = tester.widget<SignUpForm>(find.byType(SignUpForm));
    signUpForm.onSubmit(
      'username',
      'user@example.com',
      '0123456789',
      'Some address',
      'P@ssw0rd123!',
      'P@ssw0rd123!',
    );

    await tester.pumpAndSettle();

    verifyNever(() => mockAuth.saveSignupData(userId: any(named: 'userId')));
  });
}
