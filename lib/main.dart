import 'package:flutter/material.dart';
import 'homePage.dart';
import 'common/theme/app_theme.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Manager',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

// define interface (ref react interface), env const, dung ui component diiiii,
// ultil, define 1 cai APP call bo trong 1 file trong common, formik + yup cho form, 1 cai common "route"