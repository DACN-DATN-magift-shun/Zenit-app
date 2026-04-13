import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/providers/locale_provider.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';
import 'package:zenit/features/setting_childs/category_manage/screen/category_manage.dart';
import 'package:zenit/features/setting_childs/money_source_manage/screen/money_source_manage.dart';
import 'package:zenit/features/setting_childs/money_source_manage/providers/money_source_provider.dart';
import 'package:zenit/features/setting_childs/profile_details/screens/account_details.dart';
import 'package:zenit/core/services/navigation_service.dart';
import 'package:zenit/core/layout/main_shell.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/auth/screens/login.dart';
import 'package:zenit/features/setting_childs/general_settings/screens/general_settings.dart';
import 'package:zenit/features/setting_childs/notifications_setting/screens/notification_manage.dart';
import 'package:zenit/features/setting_childs/contact_us/contact_us.dart';
import 'package:zenit/features/setting_childs/terms_and_privacy/terms_and_privacy.dart';
import 'package:zenit/features/auth/screens/signup.dart';
import 'package:zenit/features/auth/screens/reset_passwords.dart';
import 'package:zenit/features/main/screens/notification.dart';
import 'package:zenit/features/main/screens/opening_splash_screen.dart';
import 'package:zenit/features/loans/screen/loans_screen.dart';
import 'package:zenit/features/loans/providers/loans_provider.dart';
import 'package:zenit/features/transfer/screen/transfer_screen.dart';
import 'package:zenit/l10n/app_localizations.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Widget _buildMainShell(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    int initialIndex = 0;
    String? initialTransactionId;
    Map<String, dynamic>? initialTransaction;

    if (arguments is Map) {
      final rawInitialIndex = arguments['initialIndex'];
      if (rawInitialIndex is int) {
        initialIndex = rawInitialIndex;
      }

      final rawTransactionId = arguments['transactionId'];
      if (rawTransactionId is String && rawTransactionId.isNotEmpty) {
        initialTransactionId = rawTransactionId;
      }

      final rawTransaction = arguments['transaction'];
      if (rawTransaction is Map) {
        initialTransaction = Map<String, dynamic>.from(rawTransaction);
      }
    }

    return MainShell(
      initialIndex: initialIndex,
      initialTransactionId: initialTransactionId,
      initialTransaction: initialTransaction,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => MoneySourceProvider()),
        ChangeNotifierProvider(create: (_) => LoansProvider()),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider()..loadSavedLocale(),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'Zenit',
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            locale: localeProvider.locale,
            supportedLocales: LocaleProvider.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            navigatorKey: NavigationService.instance.navigatorKey,
            initialRoute: '/opening',
            routes: {
              '/opening': (c) => const OpeningSplashScreen(),
              '/': (c) => _buildMainShell(c),
              '/login': (c) => const LoginScreen(),
              '/home': (c) => _buildMainShell(c),
              '/loans': (c) => const LoansScreen(),
              '/transfer': (c) => const TransferScreen(),
              '/signup': (c) => const SignupScreen(),
              '/reset-password': (c) => const ResetPasswordsScreen(),
              '/settings/account_details': (c) => const AccountDetails(),
              '/settings/category_manage': (c) => const CategoryManageScreen(),
              '/settings/money_source_manage': (c) =>
                  const MoneySourceManageScreen(),
              '/settings/general': (c) => const GeneralSettings(),
              '/settings/notifications': (c) => const NotificationManage(),
              '/settings/contact-us': (c) => const ContactUsScreen(),
              '/settings/terms-and-privacy': (c) =>
                  const TermsAndPolicyScreen(),
              '/notifications': (c) => const NotificationScreen(),
            },
          );
        },
      ),
    );
  }
}
