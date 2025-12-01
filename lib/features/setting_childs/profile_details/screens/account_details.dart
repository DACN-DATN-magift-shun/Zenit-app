import 'package:flutter/material.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/layout/base_layout.dart';
import 'package:zenit/features/setting_childs/profile_details/widgets/profile_form.dart';

class AccountDetails extends StatefulWidget {
  const AccountDetails({super.key});

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

Future<void> _handleSubmit(
  String email,
  String username,
  String dateOfBirth,
  String phone,
  String address,
) async {
  // Xử lý lưu thông tin tài khoản ở đây
}

class _AccountDetailsState extends State<AccountDetails> {
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      appBar: CommonAppBar(
        title: "Profile",
        showReturnIcon: true,
        onBack: () {
          Navigator.pop(context);
        },
      ),
      child: ProfileForm(onSubmit: _handleSubmit),
    );
  }
} 