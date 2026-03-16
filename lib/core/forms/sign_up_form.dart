import 'package:flutter/material.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/widgets/button.dart';
import 'package:zenit/core/forms/form_fields/custom_text_form_field.dart';
import 'package:zenit/core/forms/form_fields/password_form_field.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/services/navigation_service.dart';

class SignUpForm extends StatefulWidget {
  final void Function(String username, String email, String phone, String address, String password, String confirmPassword) onSubmit;

  const SignUpForm({
    super.key,
    required this.onSubmit,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _addressController.text.trim(),
        _passwordController.text,
        _confirmPasswordController.text,
      );
    }
  }

  String? _validateUsername(String? value) {
    final l10n = context.l10n;
    if (value == null || value.isEmpty) {
      return l10n.enterUsername;
    }
    if (value.length < 3 || value.length > 20) {
      return l10n.usernameLengthInvalid;
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return l10n.usernameFormatInvalid;
    }
    return null;
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
    if (value != _passwordController.text) {
      return l10n.passwordNotMatch;
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final l10n = context.l10n;
    if (value == null || value.isEmpty) {
      return l10n.enterPhone;
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return l10n.invalidPhone;
    }
    if (value.length != 10) {
      return l10n.phoneLengthInvalid;
    }
    return null;
  }

  String? _validateAddress(String? value) {
    final l10n = context.l10n;
    if (value == null || value.isEmpty) {
      return l10n.enterAddress;
    }
    if (value.length < 5) {
      return l10n.addressTooShort;
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
            label: l10n.username,
            hintText: l10n.usernameHint,
            controller: _usernameController,
            validator: _validateUsername,
          ),
          const SizedBox(height: 12),
          CustomTextFormField(
            label: l10n.email,
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
          PasswordFormField(
            label: l10n.confirmPassword,
            hintText: l10n.reenterPasswordHint,
            controller: _confirmPasswordController,
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 12),
          CustomTextFormField(
            label: l10n.phone,
            hintText: '0123456789',
            controller: _phoneController,
            validator: _validatePhone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          CustomTextFormField(
            label: l10n.address,
            hintText: l10n.enterAddressHint,
            controller: _addressController,
            validator: _validateAddress,
          ),
          const SizedBox(height: 24),
          AppButton(
            text: l10n.signupButton,
            onPressed: _handleSubmit,
            icon: Symbols.arrow_forward_rounded,
            gap: 20.0,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => NavigationService.instance.navigateTo('/login'),
            child: Text(
              l10n.alreadyHaveAccountLogin,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).extension<AppColorExtension>()!.primaryActive,
                  ),
              textAlign: TextAlign.center,
          ),
          ),
        ],
      ),
    );
  }
}
