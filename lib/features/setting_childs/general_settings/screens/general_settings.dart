import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/layout/base_layout.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/providers/locale_provider.dart';
import 'package:zenit/features/setting_childs/general_settings/widgets/settings_select_tile.dart';
// import 'package:zenit/features/setting_childs/general_settings/widgets/settings_switch_tile.dart';
import 'package:zenit/features/setting_childs/general_settings/widgets/settings_info_tile.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});
  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}
class _GeneralSettingsState extends State<GeneralSettings> {
  Future<void> _showLanguagePicker(BuildContext context) async {
    final l10n = context.l10n;
    final localeProvider = context.read<LocaleProvider>();
    final selectedCode = localeProvider.locale.languageCode;

    await showModalBottomSheet<void>(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.chooseLanguage),
              ),
              ListTile(
                title: Text(l10n.english),
                trailing: selectedCode == 'en' ? const Icon(Icons.check) : null,
                onTap: () async {
                  await localeProvider.setLocale(const Locale('en'));
                  if (!bottomSheetContext.mounted) {
                    return;
                  }
                  Navigator.pop(bottomSheetContext);
                },
              ),
              ListTile(
                title: Text(l10n.vietnamese),
                trailing: selectedCode == 'vi' ? const Icon(Icons.check) : null,
                onTap: () async {
                  await localeProvider.setLocale(const Locale('vi'));
                  if (!bottomSheetContext.mounted) {
                    return;
                  }
                  Navigator.pop(bottomSheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeProvider = context.watch<LocaleProvider>();
    final languageCode = localeProvider.locale.languageCode;

    final selectedLanguage = languageCode == 'vi'
        ? l10n.vietnamese
        : l10n.english;

    return BaseLayout(
      appBar: CommonAppBar(
        title: l10n.generalSettings,
        showReturnIcon: true,
        onBack: () {
          Navigator.pop(context);
        },
      ),
      child: ListView(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
  children: [
    SettingsSelectTile(
      title: l10n.languages,
      value: selectedLanguage,
      onTap: () => _showLanguagePicker(context),
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
      title: l10n.appVersion,
      value: l10n.appVersionValue,
    ),
  ],
)
,
    );
  }
}