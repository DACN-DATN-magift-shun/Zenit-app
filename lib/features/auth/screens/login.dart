import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';

import 'package:zenit/core/layout/auth_layout.dart';
import 'package:zenit/core/services/navigation_service.dart';
import 'package:zenit/core/forms/login_form.dart';

import 'package:zenit/core/services/auth_service.dart';
import 'package:zenit/features/auth/services/account_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _hasShownMessage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hiển thị thông báo nếu có từ navigation arguments (chỉ một lần)
    if (!_hasShownMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final snackMessage = args?['snackMessage'] as String?;
        if (snackMessage != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(snackMessage)),
          );
          _hasShownMessage = true;
        }
      });
    }
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() => _isLoading = true);

    try {
      print('Sending login request to: ${ApiEndpoints.login}');
      print('Data: email=$email');

      final response = await AccountService().login(
        email: email,
        password: password,
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      print('Response data type: ${response.data.runtimeType}');

      final responseData = response.data;
      
      // Safely extract tokens
      String? accessToken;
      String? refreshToken;
      String? errorMessage;
      
      if (responseData is Map) {
        accessToken = responseData['accessToken']?.toString();
        refreshToken = responseData['refreshToken']?.toString();
        errorMessage = responseData['message']?.toString();
      }

      if (accessToken != null && refreshToken != null) {
        await AuthService().saveLoginData(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        if (mounted) {
          NavigationService.instance.navigateTo(
            '/home',
            arguments: {'snackMessage': 'Đăng nhập thành công!'},
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage ?? 'Dữ liệu trả về lỗi'),
            ),
          );
        }
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('Response: ${e.response?.data}');
      if (mounted) {
        String serverMsg = 'Lỗi đăng nhập';
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          serverMsg = responseData['message']?.toString() ?? e.message ?? 'Lỗi đăng nhập';
        } else if (responseData is String && responseData.isNotEmpty) {
          serverMsg = responseData;
        } else if (e.message != null && e.message!.isNotEmpty) {
          serverMsg = e.message!;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(serverMsg)));
      }
    } catch (e) {
      print('General error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Welcome back!',
      subtitle: 'Log in',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoginForm(onSubmit: _handleLogin),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
