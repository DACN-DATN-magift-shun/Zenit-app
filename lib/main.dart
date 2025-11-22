import 'package:flutter/material.dart';
import 'package:zenit/common/utils/services/navigation_service.dart';
import 'package:zenit/screens/main_screen/homepage.dart';
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
      initialRoute: '/',
      routes: {
        '/': (c) => HomePage(),
        // (c) => const HomePage() là 1 hàm builder trả về widget HomePage
        '/login': (c) => const LoginScreen(),
        '/home': (c) => const HomePage(),
        '/signup': (c) => const SignupScreen(),

      }
    );
  }
}

// define interface (ref react interface), env const, dung ui component diiiii,
// ultil, define 1 cai APP call bo trong 1 file trong common, formik + yup cho form, 1 cai common "route"