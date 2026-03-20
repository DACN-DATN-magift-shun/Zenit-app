import 'package:flutter/material.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/widgets/button.dart';
import 'package:zenit/core/forms/form_fields/custom_text_form_field.dart';
import 'package:zenit/core/forms/form_fields/password_form_field.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/services/navigation_service.dart';
import 'package:zenit/core/widgets/auth_language_toggle.dart';

class LoginForm extends StatefulWidget {
  final void Function(String email, String password) onSubmit;

  const LoginForm({super.key, required this.onSubmit});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_emailController.text.trim(), _passwordController.text);
    }
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
    final hasSpecial = RegExp(
      r'[!@#\$%\^&\*\(\)\+\=\{\}\[\]:;"\\<>,\.\?\/\\|~`_ -]',
    ).hasMatch(value);
    if (!hasNumber || !hasSpecial) {
      return l10n.weakPassword;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextFormField(
            label: l10n.email,
            labelTrailing: const AuthLanguageToggle(),
            hintText: l10n.emailHint,
            controller: _emailController,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          PasswordFormField(
            label: l10n.password,
            hintText: l10n.enterPasswordHint,
            controller: _passwordController,
            validator: _validatePassword,
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () =>
                NavigationService.instance.navigateTo('/reset-password'),
            child: Text(
              l10n.forgotPassword,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).extension<AppColorExtension>()!.primaryActive,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: l10n.loginButton,
            onPressed: _handleSubmit,
            icon: Symbols.arrow_forward_rounded,
            gap: 20.0,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => NavigationService.instance.navigateTo('/signup'),
            child: Text(
              l10n.noAccountSignup,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).extension<AppColorExtension>()!.primaryActive,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.loginTermsText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).extension<AppColorExtension>()!.neutralTextDisable,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
