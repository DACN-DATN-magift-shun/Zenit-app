import 'package:flutter/material.dart';
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
    return BaseLayout(
      appBar: CommonAppBar(
        title: 'Notification',
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
            title: 'Receive our update via email',
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
