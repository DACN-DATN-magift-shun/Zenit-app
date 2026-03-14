import 'package:flutter/material.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/layout/base_layout.dart';
import 'package:zenit/features/auth/services/account_service.dart';
import 'package:zenit/features/setting_childs/profile_details/widgets/profile_form.dart';

class AccountDetails extends StatefulWidget {
  const AccountDetails({super.key});

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  final AccountService _accountService = AccountService();

  Future<void> _handleSubmit(String phone, String address) async {
    try {
      final response = await _accountService.updateMyAccount(
        phone: phone,
        address: address,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to update profile')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update profile')),
      );
    }
  }

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