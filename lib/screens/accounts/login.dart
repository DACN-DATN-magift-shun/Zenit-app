import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/common/layout/auth_layout.dart';
import 'package:zenit/common/widgets/input_field.dart';
import 'package:zenit/common/widgets/password_field.dart';
import 'package:zenit/common/constants/theme/app_theme.dart';
import 'package:zenit/common/widgets/button.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    return AuthLayout(
      title: 'Welcome back !',
      subtitle: 'Sign In',
      // nút nhỏ để quay về trang chủ - dev only - to line 37
      leading: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Material(
              color: appColors.primaryText.withOpacity(0.24),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: Icon(Icons.arrow_back_ios_new, size: 18, color: appColors.primaryText),
              ),
            ),
          ),
        ),
      ),
      // keep the drawer content as the child
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text('Email or username', style: TextStyle(fontWeight: FontWeight.bold, color: appColors.secondarySubtext)),
          const SizedBox(height: 8),
          InputField(hintText: 'Akitoshi_dou_374'),
          const SizedBox(height: 20),
          Text('Passwords', style: TextStyle(fontWeight: FontWeight.bold, color: appColors.secondarySubtext)),
          const SizedBox(height: 8),
          PasswordField(hintText: '123456@Zenit'),
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerRight, child: Text('Forgot password ?', style: TextStyle(color: appColors.primaryActive, fontSize: 12, fontWeight: FontWeight.w500))),
          const SizedBox(height: 28),
          Center(
            child: AppButton(
              text: 'Sign In',
              onPressed: () {},
              icon: Symbols.arrow_forward_rounded,
              gap: 20.0,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            ),
          ),
          const SizedBox(height: 14),
          Center(child: Text('Or if not already have account', style: TextStyle(fontSize: 12, color: appColors.neutralTextSecondary))),
          const SizedBox(height: 14),
          Center(
            child: AppButton(
              text: 'Sign Up',
              icon: Symbols.arrow_upward_rounded,
              gap: 20.0,
              onPressed: () {},
              type: AppButtonType.outline,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Center(child: Text('By continue, you agree with our terms and privacy policy', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: appColors.neutralTextSecondary))),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
