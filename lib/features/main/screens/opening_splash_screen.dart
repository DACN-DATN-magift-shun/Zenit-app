import 'package:flutter/material.dart';
import 'package:zenit/core/services/auth_service.dart';

class OpeningSplashScreen extends StatefulWidget {
  const OpeningSplashScreen({super.key});

  @override
  State<OpeningSplashScreen> createState() => _OpeningSplashScreenState();
}

class _OpeningSplashScreenState extends State<OpeningSplashScreen> {
  static const _displayDuration = Duration(milliseconds: 1200);
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _resolveStartRoute();
  }

  Future<void> _resolveStartRoute() async {
    try {
      await Future.delayed(_displayDuration);
      if (!mounted) return;

      final isAuthenticated = await _authService.isAuthenticated();
      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(
        isAuthenticated ? '/home' : '/login',
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: _OpeningSplashBody(),
    );
  }
}

class _OpeningSplashBody extends StatelessWidget {
  const _OpeningSplashBody();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: Image.asset(
        'assets/images/opening_screen_white_bg.png',
        width: width * 0.72,
        fit: BoxFit.contain,
      ),
    );
  }
}
