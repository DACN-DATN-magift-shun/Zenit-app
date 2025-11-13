import 'package:flutter/material.dart';
import 'package:zenit/common/constants/theme/app_colors.dart';
import 'package:zenit/common/widgets/input_field.dart';
import 'package:zenit/common/widgets/password_field.dart';
import 'package:zenit/common/constants/theme/app_typography.dart';
import 'package:zenit/common/constants/theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final statusBar = MediaQuery.of(context).padding.top;

    // Giá trị này điều chỉnh "độ trồi" của drawer lên (thay đổi nếu cần)
    final headerPortion = 0.35; // phần header xanh so với chiều cao màn
    final drawerPeekPortion = 0.25; // vị trí top của drawer (so với height)

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Header xanh: bắt đầu từ top = 0, cover luôn status bar (notch)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            // thêm statusBar vào height để cover tai thỏ
            height: size.height * headerPortion + statusBar,
            child: Container(
              width: double.infinity,
              color: Theme.of(context).extension<AppColorExtension>()!.primaryMain,
              // padding top = statusBar để nội dung header không chạm notch
              padding: EdgeInsets.only(top: statusBar + 20),
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome back !',
                    style: AppTypography.textThemeLight.headlineLarge
                        ?.copyWith(color: Theme.of(context).extension<AppColorExtension>()!.primaryText,),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign In',
                    style: TextStyle(
                      color: Theme.of(context).extension<AppColorExtension>()!.primaryText,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SafeArea(
                      top: true,
                      bottom: false,
                      child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Material(
                          color: Theme.of(context).extension<AppColorExtension>()!.primaryText.withOpacity(0.24),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            // Navigate back to the app's first route (homepage)
                            onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                              color: Theme.of(context).extension<AppColorExtension>()!.primaryText,
                            ),
                          ),
                        ),
                      ),
                      ),
                    ),
                    )
                ],
              ),
            ),
          ),

          // Drawer trắng: phủ từ bottom=0 tới top = (drawerPeekPortion * height) + statusBar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: size.height * drawerPeekPortion + statusBar,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  )
                ],
              ),
              child: SafeArea(
                top: false, // SafeArea chỉ dùng cho nội dung, không ảnh hưởng header
                bottom: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'Email or username',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.light.secondarySubtext),
                      ),
                      const SizedBox(height: 8),
                      InputField(
                        hintText: 'Akitoshi_dou_374',
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Passwords',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.light.secondarySubtext),
                      ),
                      const SizedBox(height: 8),
                      PasswordField(
                        hintText: '123456@Zenit',
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Forgot password ?',
                          style: TextStyle(
                              color: AppColors.light.primaryActive,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.light.primaryMain,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 6,
                          ),
                          icon: const Icon(Icons.arrow_forward, color: Colors.white),
                          label: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          'Or if not already have account',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).extension<AppColorExtension>()!.neutralTextSecondary),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 75, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 6,
                            side: BorderSide(color: Theme.of(context).extension<AppColorExtension>()!.primaryMain),
                          ),
                          icon: Icon(Icons.arrow_upward, color: Theme.of(context).extension<AppColorExtension>()!.primaryMain),
                          label: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Theme.of(context).extension<AppColorExtension>()!.primaryMain,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: EdgeInsets.only(top: 48),
                        child: Center(
                          child: Text(
                            'By continue, you agree with our terms and privacy policy',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10, color: Theme.of(context).extension<AppColorExtension>()!.neutralTextSecondary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
