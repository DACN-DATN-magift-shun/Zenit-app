import 'package:flutter/material.dart';
import 'package:zenit/core/layout/base_layout.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/features/setting_childs/general_settings/widgets/settings_select_tile.dart';
// import 'package:zenit/features/setting_childs/general_settings/widgets/settings_switch_tile.dart';
import 'package:zenit/features/setting_childs/general_settings/widgets/settings_info_tile.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});
  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}
class _GeneralSettingsState extends State<GeneralSettings> {
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      appBar: CommonAppBar(
        title: 'General Settings',
        showReturnIcon: true,
        onBack: () {
          Navigator.pop(context);
        },
      ),
      child: ListView(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
  children: [
    SettingsSelectTile(
      title: 'Languages',
      value: 'English',
      onTap: () {},
    ),

    // SettingsSelectTile(
    //   title: 'Display',
    //   value: 'Light',
    //   onTap: () {},
    // ),

    // const SizedBox(height: 12),

    // SettingsSwitchTile(
    //   title: 'AI-Execution Simulator',
    //   description:
    //       'AI command execution with step-by-step UI visualization, this may make your device slower in some case.',
    //   value: isAiSimulatorEnabled,
    //   onChanged: (v) {},
    // ),

    // const SizedBox(height: 24),

    SettingsInfoTile(
      title: 'App version',
      value: '1.0 (beta)',
    ),
  ],
)
,
    );
  }
}