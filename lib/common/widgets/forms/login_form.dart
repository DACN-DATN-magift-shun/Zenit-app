import 'package:flutter/material.dart';
import 'package:zenit/common/widgets/button.dart';
import 'package:zenit/common/widgets/form_fields/custom_text_form_field.dart';
import 'package:zenit/common/widgets/form_fields/password_form_field.dart';
import 'package:zenit/common/utils/validators/auth_forms_validator.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/common/constants/theme/app_theme.dart';
import 'package:zenit/common/utils/services/navigation_service.dart';
class LoginForm extends StatefulWidget {
  final void Function(String email, String password) onSubmit;

  const LoginForm({
    super.key,
    required this.onSubmit,
  });

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
      widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
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
          Text(
            'Quên mật khẩu?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).extension<AppColorExtension>()!.primaryActive,
          ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Đăng nhập',
            onPressed: _handleSubmit,
            icon: Symbols.arrow_forward_rounded,
            gap: 20.0,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => NavigationService.instance.navigateTo('/signup'),
            child: Text(
              'Bạn chưa có tài khoản? Đăng ký ngay',
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