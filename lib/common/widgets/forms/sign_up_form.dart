import 'package:flutter/material.dart';
import 'package:zenit/common/widgets/button.dart';
import 'package:zenit/common/widgets/form_fields/custom_text_form_field.dart';
import 'package:zenit/common/widgets/form_fields/password_form_field.dart';
import 'package:zenit/common/utils/validators/auth_forms_validator.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/common/constants/theme/app_theme.dart';
import 'package:zenit/services/navigation_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextFormField(
            label: 'Tên người dùng',
            hintText: 'username',
            controller: _usernameController,
            validator: AuthFormsValidator.username,
          ),
          const SizedBox(height: 12),
          CustomTextFormField(
            label: 'Email',
            hintText: 'your.email@example.com',
            controller: _emailController,
            validator: AuthFormsValidator.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          PasswordFormField(
            label: 'Mật khẩu',
            hintText: 'Nhập mật khẩu',
            controller: _passwordController,
            validator: AuthFormsValidator.password,
          ),
          const SizedBox(height: 12),
          PasswordFormField(
            label: 'Xác nhận mật khẩu',
            hintText: 'Nhập lại mật khẩu',
            controller: _confirmPasswordController,
            validator: AuthFormsValidator.confirmPassword(() => _passwordController.text),
          ),
          const SizedBox(height: 12),
          CustomTextFormField(
            label: 'Số điện thoại',
            hintText: '0123456789',
            controller: _phoneController,
            validator: AuthFormsValidator.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          CustomTextFormField(
            label: 'Địa chỉ',
            hintText: 'Nhập địa chỉ của bạn',
            controller: _addressController,
            validator: AuthFormsValidator.address,
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Đăng ký',
            onPressed: _handleSubmit,
            icon: Symbols.arrow_forward_rounded,
            gap: 20.0,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => NavigationService.instance.navigateTo('/login'),
            child: Text(
              'Bạn đã có tài khoản? Đăng nhập',
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
