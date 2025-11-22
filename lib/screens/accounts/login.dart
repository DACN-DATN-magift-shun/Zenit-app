import 'package:flutter/material.dart';
import 'package:zenit/common/layout/auth_layout.dart';
import 'package:zenit/common/utils/services/navigation_service.dart';
import 'package:zenit/common/widgets/forms/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void onSubmit(String email, String password) {
      NavigationService.instance.navigateTo('/home');
    }
    return AuthLayout(
      title: 'Welcome back !',
      subtitle: 'Sign In',
      // keep the drawer content as the child
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoginForm(onSubmit: onSubmit)
        ],
      ),
    );
  }
}
