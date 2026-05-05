import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/setting_childs/general_settings/widgets/settings_info_tile.dart';
import 'package:zenit/features/setting_childs/general_settings/widgets/settings_select_tile.dart';
import 'package:zenit/features/setting_childs/notifications_setting/widgets/notification_setting_item.dart';

import '../../../../fixtures/features/setting_childs/general_settings/settings_widget_fixtures.dart';

void main() {
  group('Settings widgets', () {
    testWidgets('SettingsSelectTile handles taps', (tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: SettingsSelectTile(
              title: settingsWidgetLanguageLabel,
              value: settingsWidgetLanguageValue,
              onTap: () => tapCount += 1,
            ),
          ),
        ),
      );

      expect(find.text(settingsWidgetLanguageLabel), findsOneWidget);
      expect(find.text(settingsWidgetLanguageValue), findsOneWidget);

      await tester.tap(find.text(settingsWidgetLanguageLabel));
      await tester.pump();

      expect(tapCount, 1);
    });

    testWidgets('SettingsInfoTile renders title and value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: const Scaffold(
            body: SettingsInfoTile(
              title: settingsWidgetAccountLabel,
              value: settingsWidgetAccountValue,
            ),
          ),
        ),
      );

      expect(find.text(settingsWidgetAccountLabel), findsOneWidget);
      expect(find.text(settingsWidgetAccountValue), findsOneWidget);
    });

    testWidgets('NotificationSettingItem toggles value', (tester) async {
      var currentValue = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: NotificationSettingItem(
              title: 'Push notifications',
              value: currentValue,
              onChanged: (value) {
                currentValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(currentValue, true);
    });
  });
}