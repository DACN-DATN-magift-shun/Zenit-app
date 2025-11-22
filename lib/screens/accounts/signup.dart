import 'package:flutter/material.dart';
import 'package:zenit/common/layout/auth_layout.dart';
import 'package:zenit/common/utils/services/navigation_service.dart';
import 'package:zenit/common/widgets/forms/sign_up_form.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void onSubmit(String email, String password, String confirmPassword) {
      NavigationService.instance.navigateTo('/home');
    }
    return AuthLayout(
      title: 'Welcome back !',
      subtitle: 'Sign In',
      // keep the drawer content as the child
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SignUpForm(onSubmit: onSubmit)
        ],
      ),
    );
  }
}
