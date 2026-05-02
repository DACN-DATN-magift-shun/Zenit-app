import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import 'package:zenit/features/auth/screens/login.dart';
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

  testWidgets('LoginScreen successful login calls saveLoginData', (tester) async {
    final mockAccount = MockAccountService();
    final mockAuth = MockAuthService();

    when(() => mockAccount.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => buildResponse(statusCode: 200, data: {
              'accessToken': 'at',
              'refreshToken': 'rt',
            }));

    when(() => mockAuth.saveLoginData(accessToken: any(named: 'accessToken'), refreshToken: any(named: 'refreshToken')))
        .thenAnswer((_) async {});

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: MaterialApp(
          theme: lightTheme,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: LoginScreen(accountService: mockAccount, authService: mockAuth)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
    // enter a strong password matching validation rules
    await tester.enterText(find.byType(TextFormField).last, 'P@ssw0rd123!');
    await tester.pump();

    await tester.tap(find.widgetWithText(AppButton, 'Log in'));
    await tester.pumpAndSettle();

    verify(() => mockAuth.saveLoginData(accessToken: 'at', refreshToken: 'rt')).called(1);
  });

  testWidgets('LoginScreen shows error on DioException', (tester) async {
    final mockAccount = MockAccountService();
    final mockAuth = MockAuthService();

    when(() => mockAccount.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenThrow(DioException(requestOptions: RequestOptions(path: ''), type: DioExceptionType.receiveTimeout));

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: MaterialApp(
          theme: lightTheme,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: LoginScreen(accountService: mockAccount, authService: mockAuth)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'P@ssw0rd123!');
    await tester.pump();

    await tester.tap(find.widgetWithText(AppButton, 'Log in'));
    await tester.pumpAndSettle();

    // Ensure saveLoginData was not called
    verifyNever(() => mockAuth.saveLoginData(accessToken: any(named: 'accessToken'), refreshToken: any(named: 'refreshToken')));
  });
}
