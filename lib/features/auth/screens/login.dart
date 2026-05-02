import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/core/l10n/l10n.dart';

import 'package:zenit/core/layout/auth_layout.dart';
import 'package:zenit/core/services/navigation_service.dart';
import 'package:zenit/core/forms/login_form.dart';
import 'package:zenit/core/widgets/app_flash.dart';

import 'package:zenit/core/services/auth_service.dart';
import 'package:zenit/core/utils/auth_error_message.dart';
import 'package:zenit/features/auth/services/account_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.accountService, this.authService});

  final AccountService? accountService;
  final dynamic authService;
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
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final snackMessage = args?['snackMessage'] as String?;
        if (snackMessage != null && mounted) {
          AppFlash.success(context, snackMessage);
          _hasShownMessage = true;
        }
      });
    }
  }

  Future<void> _handleLogin(String email, String password) async {
    final l10n = context.l10n;
    setState(() => _isLoading = true);

    try {
      print('Sending login request to: ${ApiEndpoints.login}');
      print('Data: email=$email');

      final response = await (widget.accountService ?? AccountService()).login(
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
        final auth = widget.authService ?? AuthService();
        await auth.saveLoginData(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        if (mounted) {
          NavigationService.instance.pushAndRemoveUntil(
            '/home',
            arguments: {'snackMessage': l10n.loginSuccess},
          );
        }
      } else {
        if (mounted) {
          AppFlash.error(
            context,
            AuthErrorMessage.resolve(
              context: context,
              responseData: responseData,
              fallback: errorMessage ?? l10n.invalidResponseData,
            ),
          );
        }
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('Response: ${e.response?.data}');
      if (mounted) {
        final serverMsg = AuthErrorMessage.resolve(
          context: context,
          responseData: e.response?.data,
          fallback: l10n.loginError,
        );
        AppFlash.error(context, serverMsg);
      }
    } catch (e) {
      print('General error: $e');
      if (mounted) {
        AppFlash.error(context, l10n.unknownErrorWithReason(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AuthLayout(
      title: l10n.loginTitle,
      subtitle: l10n.loginSubtitle,
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
