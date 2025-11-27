import 'package:flutter/material.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/layout/main_layout.dart';
import 'package:zenit/core/services/auth_service.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final AuthService _authService = AuthService();
  
  String _userName = '';
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);
    
    final isAuth = await _authService.isAuthenticated();
    
    if (isAuth) {
      final response = await _authService.getUserInfo();
      
      if (response != null && response.statusCode == 200) {
        setState(() {
          _isAuthenticated = true;
          _userName = response.data['username'] ?? 'User';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MainLayout(
      appBar: CommonAppBar(
        title: _isAuthenticated 
            ? 'Welcome back, $_userName' 
            : 'Home - Bạn chưa đăng nhập',
        showSecondaryText: _isAuthenticated,
        secondaryText: _isAuthenticated ? "Have a nice day!" : null,
      ),
      child: SingleChildScrollView(

      ),
    );
  }
}
