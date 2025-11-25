import 'package:flutter/material.dart';
import 'package:zenit/services/navigation_service.dart';
import 'package:zenit/common/layout/main_shell.dart';
import 'package:zenit/common/constants/theme/app_theme.dart';
import 'package:zenit/screens/accounts/login.dart';
import 'package:zenit/screens/accounts/signup.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zenit',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      navigatorKey: NavigationService.instance.navigatorKey,
      initialRoute: '/login',
      routes: {
        '/': (c) => const MainShell(),
        '/login': (c) => const LoginScreen(),
        '/home': (c) => const MainShell(),
        '/signup': (c) => const SignupScreen(),

      }
    );
  }
}

