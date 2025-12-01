import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';
import 'package:zenit/features/setting_childs/category_manage/screen/category_manage.dart';
import 'package:zenit/features/setting_childs/profile_details/screens/account_details.dart';
import 'package:zenit/core/services/navigation_service.dart';
import 'package:zenit/core/layout/main_shell.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/auth/screens/login.dart';
import 'package:zenit/features/auth/screens/signup.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        // Thêm các provider khác ở đây nếu cần
      ],
      child: MaterialApp(
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
          '/settings/account_details': (c) => const AccountDetails(),
          '/settings/category_manage': (c) => const CategoryManageScreen(),

        }
      ),
    );
  }
}

