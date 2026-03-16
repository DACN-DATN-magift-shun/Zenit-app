import 'package:flutter/material.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/layout/base_layout.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/features/setting_childs/notifications_setting/widgets/notification_setting_item.dart';

class NotificationManage extends StatefulWidget {
  const NotificationManage({super.key});

  @override
  State<NotificationManage> createState() => _NotificationManageState();
}

class _NotificationManageState extends State<NotificationManage> {
  bool _receiveEmailUpdates = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BaseLayout(
      appBar: CommonAppBar(
        title: l10n.notificationManageTitle,
        showReturnIcon: true,
        onBack: () {
          Navigator.pop(context);
        },
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          const SizedBox(height: AppSizes.s),
          NotificationSettingItem(
            title: l10n.receiveEmailUpdates,
            value: _receiveEmailUpdates,
            onChanged: (value) {
              setState(() {
                _receiveEmailUpdates = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
