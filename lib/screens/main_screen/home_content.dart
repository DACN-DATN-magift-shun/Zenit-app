import 'package:flutter/material.dart';
import 'package:zenit/common/layout/app_bar.dart';
import 'package:zenit/common/widgets/button.dart';
import 'package:zenit/services/auth_service.dart';
import 'package:zenit/services/navigation_service.dart';

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

    return Scaffold(
      appBar: CommonAppBar(
        title: _isAuthenticated 
            ? 'Welcome back, $_userName' 
            : 'Home - Bạn chưa đăng nhập',
        showSecondaryText: _isAuthenticated,
        secondaryText: _isAuthenticated ? "Have a nice day!" : null,
      ),
      body: Center(
        child: AppButton(
          text: 'logout',
          onPressed: () {
            NavigationService.instance.navigateTo('/login');
            AuthService().logout();
          },
        ),
      ),
    );
  }
}
