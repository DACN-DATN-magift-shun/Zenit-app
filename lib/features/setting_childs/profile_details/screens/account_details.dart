import 'package:flutter/material.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/layout/base_layout.dart';
import 'package:zenit/core/widgets/app_flash.dart';
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
    final l10n = context.l10n;
    try {
      final response = await _accountService.updateMyAccount(
        phone: phone,
        address: address,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        AppFlash.success(context, l10n.profileUpdatedSuccess);
      } else {
        AppFlash.error(context, l10n.unableUpdateProfile);
      }
    } catch (_) {
      if (!mounted) return;
      AppFlash.error(context, l10n.unableUpdateProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BaseLayout(
      appBar: CommonAppBar(
        title: l10n.profile,
        showReturnIcon: true,
        onBack: () {
          Navigator.pop(context);
        },
      ),
      child: ProfileForm(onSubmit: _handleSubmit),
    );
  }
} 