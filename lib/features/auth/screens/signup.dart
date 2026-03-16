import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/layout/auth_layout.dart';
import 'package:zenit/core/services/navigation_service.dart';
import 'package:zenit/core/forms/sign_up_form.dart';
import 'package:zenit/core/widgets/app_flash.dart';
import 'package:zenit/data/local/storage_service.dart';
import 'package:zenit/features/auth/services/account_service.dart';
import 'package:zenit/core/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();

}
class _SignupScreenState extends State<SignupScreen>{
  bool _isLoading = false;
  Future<void> _handleSignup(String username, String email, String phone, String address, String password, String confirmPassword) async {
    final l10n = context.l10n;
    setState(() => _isLoading = true);
    try {
      print('Sending request to: ${ApiEndpoints.register}');
      print('Data: username=$username, email=$email, phone=$phone, address=$address');
      
      final respone = await  AccountService().register(
        username: username,
        email: email,
        phone: phone,
        address: address,
        password: password,
      );
      
      print('Response: ${respone.data}');
      final responeData = respone.data;
      final userID = responeData['id'];
      AuthService().saveSignupData(
        userId: responeData['id'].toString(),
      );
      if(userID != null){
        if (mounted) {
          StorageService().saveUserId(userID.toString());
          NavigationService.instance.navigateTo(
            '/login',
            arguments: {'snackMessage': l10n.signupSuccessPleaseLogin},
          );
        }
      } else {
        if(mounted){
          AppFlash.error(context, respone.data['message'] ?? l10n.invalidResponseData);
        }
      }
      
      
    } on DioException catch(e){
      if (mounted) {
        final serverMsg = e.response?.data?['message'] ?? e.message;
        AppFlash.error(context, serverMsg ?? l10n.signupError);
      }
    }
     catch (e) {
      if (mounted) {
        AppFlash.error(context, l10n.unknownErrorOccurred);
      }
      
    }
    finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
    @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AuthLayout(
      title: l10n.signupTitle,
      subtitle: l10n.signupSubtitle,
      // keep the drawer content as the child
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SignUpForm(onSubmit: _handleSignup),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

