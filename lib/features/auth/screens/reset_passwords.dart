import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/layout/auth_layout.dart';
import 'package:zenit/core/services/navigation_service.dart';
import 'package:zenit/core/widgets/app_flash.dart';
import 'package:zenit/core/widgets/button.dart';
import 'package:zenit/core/forms/form_fields/custom_text_form_field.dart';
import 'package:zenit/core/forms/form_fields/password_form_field.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/auth/services/account_service.dart';
import 'package:material_symbols_icons/symbols.dart';

class ResetPasswordsScreen extends StatefulWidget {
  const ResetPasswordsScreen({super.key});

  @override
  State<ResetPasswordsScreen> createState() => _ResetPasswordsScreenState();
}

class _ResetPasswordsScreenState extends State<ResetPasswordsScreen> {
  bool _isLoading = false;
  bool _otpSent = false;
  int _countdown = 24; // Countdown timer in seconds (24s as shown in UI)
  
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _countdown = 24);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _countdown--);
      return _countdown > 0;
    });
  }

  String? _validateEmail(String? value) {
    final l10n = context.l10n;
    if (value == null || value.isEmpty) {
      return l10n.enterEmail;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return l10n.invalidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final l10n = context.l10n;
    if (value == null || value.isEmpty) {
      return l10n.enterPassword;
    }
    if (value.length <= 8) {
      return l10n.weakPassword;
    }
    final hasNumber = RegExp(r'\d').hasMatch(value);
    final hasSpecial = RegExp(r'[!@#\$%\^&\*\(\)\+\=\{\}\[\]:;"\\<>,\.\?\/\\|~`_ -]').hasMatch(value);
    if (!hasNumber || !hasSpecial) {
      return l10n.weakPassword;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final l10n = context.l10n;
    if (value == null || value.isEmpty) {
      return l10n.confirmPasswordRequired;
    }
    if (value != _newPasswordController.text) {
      return l10n.passwordNotMatch;
    }
    return null;
  }

  Future<void> _handleSendOTP() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await AccountService().sendOtp(
        email: _emailController.text.trim(),
      );

      print('Send OTP Response: ${response.data}');

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] ?? false;
        final message = responseData['message']?.toString() ?? l10n.otpSentInstruction;
        
        if (mounted) {
          if (success) {
            AppFlash.success(context, message);
          } else {
            AppFlash.error(context, message);
          }
          
          if (success) {
            setState(() {
              _otpSent = true;
            });
            _startCountdown();
          }
        }
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('Response: ${e.response?.data}');
      if (mounted) {
        String serverMsg = l10n.sendOtpError;
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          serverMsg = responseData['message']?.toString() ??
              e.message ??
              l10n.sendOtpError;
        } else if (responseData is String && responseData.isNotEmpty) {
          serverMsg = responseData;
        } else if (e.message != null && e.message!.isNotEmpty) {
          serverMsg = e.message!;
        }
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

  Future<void> _handleResetPassword() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Bước 1: Verify OTP trước
      final verifyResponse = await AccountService().verifyOtp(
        email: _emailController.text.trim(),
        otpCode: _otpController.text.trim(),
      );

      print('Verify OTP Response: ${verifyResponse.data}');

      final verifyData = verifyResponse.data;
      bool otpValid = false;

      if (verifyData is Map<String, dynamic>) {
        otpValid = verifyData['success'] ?? false;
        final message = verifyData['message']?.toString();
        
        if (!otpValid && mounted) {
          AppFlash.error(context, message ?? l10n.invalidOtp);
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      }

      // Bước 2: Nếu OTP hợp lệ, tiến hành reset password
      if (otpValid) {
        final resetResponse = await AccountService().resetPassword(
          email: _emailController.text.trim(),
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

        print('Reset Password Response: ${resetResponse.data}');

        final resetData = resetResponse.data;
        if (resetData is Map<String, dynamic>) {
          final success = resetData['success'] ?? false;
          final message = resetData['message']?.toString() ?? l10n.resetPasswordSuccess;

          if (mounted) {
            if (success) {
              NavigationService.instance.navigateTo(
                '/login',
                arguments: {
                  'snackMessage': l10n.resetPasswordSuccessNavigate
                },
              );
            } else {
              AppFlash.error(context, message);
            }
          }
        }
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('Response: ${e.response?.data}');
      if (mounted) {
        String serverMsg = l10n.resetPasswordError;
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          serverMsg = responseData['message']?.toString() ??
              e.message ??
              l10n.resetPasswordError;
        } else if (responseData is String && responseData.isNotEmpty) {
          serverMsg = responseData;
        } else if (e.message != null && e.message!.isNotEmpty) {
          serverMsg = e.message!;
        }
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
      title: l10n.forgotPasswordTitle,
      subtitle: l10n.resetPasswordSubtitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextFormField(
              label: l10n.registeredEmailOrUsername,
              hintText: l10n.emailHint,
              controller: _emailController,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              enabled: !_otpSent,
            ),
            if (!_otpSent) ...[
              const SizedBox(height: 8),
              Text(
                l10n.otpSentInstruction,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .extension<AppColorExtension>()!
                          .neutralTextDisable,
                    ),
              ),
            ],
            const SizedBox(height: 24),
            if (!_otpSent) ...[
              AppButton(
                text: l10n.send,
                onPressed: _isLoading ? null : _handleSendOTP,
                icon: Symbols.arrow_circle_right_rounded,
                gap: 20.0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
            ],
            if (_otpSent) ...[
              CustomTextFormField(
                label: l10n.otp,
                hintText: l10n.otpHint,
                controller: _otpController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterOtp;
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              if (_countdown > 0)
                Text(
                  l10n.resendAfterSeconds(_countdown),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .extension<AppColorExtension>()!
                            .neutralTextDisable,
                      ),
                ),
              if (_countdown <= 0)
                InkWell(
                  onTap: _handleSendOTP,
                  child: Text(
                    l10n.resendNow,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .extension<AppColorExtension>()!
                              .primaryActive,
                        ),
                  ),
                ),
              const SizedBox(height: 16),
              PasswordFormField(
                label: l10n.newPassword,
                hintText: '• • • • • • • •',
                controller: _newPasswordController,
                validator: _validatePassword,
              ),
              const SizedBox(height: 16),
              PasswordFormField(
                label: l10n.confirmNewPassword,
                hintText: '• • • • • •',
                controller: _confirmPasswordController,
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.resetPasswordHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .extension<AppColorExtension>()!
                          .neutralTextDisable,
                    ),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: l10n.confirm,
                onPressed: _isLoading ? null : _handleResetPassword,
                icon: Symbols.arrow_circle_right_rounded,
                gap: 20.0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              l10n.continueTermsText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .extension<AppColorExtension>()!
                        .neutralTextDisable,
                  ),
              textAlign: TextAlign.center,
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
