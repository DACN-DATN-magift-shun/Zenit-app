import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';
import 'package:zenit/features/setting_childs/money_source_manage/providers/money_source_provider.dart';
import 'package:zenit/features/setting_childs/money_source_manage/widgets/money_source_list_item.dart';
import 'package:zenit/features/setting_childs/money_source_manage/widgets/money_source_selector_drawer.dart';
import 'package:zenit/features/setting_childs/money_source_manage/widgets/single_money_source.dart';
import 'package:zenit/l10n/app_localizations.dart';

import '../../../../fixtures/features/setting_childs/money_source_manage/money_source_widget_fixtures.dart';
import '../../../../mocks/features/setting_childs/money_source_manage/money_source_provider_widget_mock.dart';

Widget _buildApp({
  required MoneySourceProvider provider,
  required void Function(MoneySourceModel) onWalletSelected,
  MoneySourceModel? selectedWallet,
}) {
  return ChangeNotifierProvider<MoneySourceProvider>.value(
    value: provider,
    child: MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: MoneySourceSelectorDrawer(
          selectedWallet: selectedWallet,
          onWalletSelected: onWalletSelected,
        ),
      ),
    ),
  );
}

void main() {
  group('Money source widgets', () {
    testWidgets('SingleMoneySource renders and handles taps', (tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: SingleMoneySource(
              name: moneySourceWidgetCash.name,
              icon: moneySourceWidgetCash.iconData,
              iconColor: moneySourceWidgetCash.iconColor,
              backgroundColor: moneySourceWidgetCash.backgroundColor,
              onTap: () => tapCount += 1,
            ),
          ),
        ),
      );

      expect(find.text('Cash'), findsOneWidget);

      await tester.tap(find.text('Cash'));
      await tester.pump();

      expect(tapCount, 1);
    });

    testWidgets('MoneySourceListItem shows note and formatted amount', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: MoneySourceListItem(moneySource: moneySourceWidgetCash),
          ),
        ),
      );

      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Pocket money'), findsOneWidget);
      expect(find.text('1.200đ'), findsOneWidget);
    });

    testWidgets('MoneySourceListItem delete action invokes callback', (
      tester,
    ) async {
      var deleteCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: MoneySourceListItem(
              moneySource: moneySourceWidgetCash,
              onDelete: () => deleteCount += 1,
            ),
          ),
        ),
      );

      await tester.drag(find.byType(Slidable), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deleteCount, 1);
    });

    testWidgets('shows loading indicator when provider is loading', (
      tester,
    ) async {
      final provider = MockMoneySourceProvider();
      when(() => provider.isLoading).thenReturn(true);
      when(() => provider.errorMessage).thenReturn(null);
      when(() => provider.hasData).thenReturn(true);
      when(() => provider.moneySources).thenReturn(const <MoneySourceModel>[]);

      await tester.pumpWidget(
        _buildApp(provider: provider, onWalletSelected: (_) {}),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state and loads wallets when data is missing', (
      tester,
    ) async {
      final provider = MockMoneySourceProvider();
      when(() => provider.isLoading).thenReturn(false);
      when(() => provider.errorMessage).thenReturn(null);
      when(() => provider.hasData).thenReturn(false);
      when(() => provider.moneySources).thenReturn(const <MoneySourceModel>[]);
      when(() => provider.loadAllMoneySources()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        _buildApp(provider: provider, onWalletSelected: (_) {}),
      );
      await tester.pump();

      expect(find.text('No data yet'), findsOneWidget);
      verify(() => provider.loadAllMoneySources()).called(1);
    });

    testWidgets('filters wallets and returns selected wallet', (tester) async {
      final provider = MockMoneySourceProvider();
      final wallets = buildMoneySourceWidgetList();
      when(() => provider.isLoading).thenReturn(false);
      when(() => provider.errorMessage).thenReturn(null);
      when(() => provider.hasData).thenReturn(true);
      when(() => provider.moneySources).thenReturn(wallets);

      MoneySourceModel? selected;

      await tester.pumpWidget(
        _buildApp(
          provider: provider,
          selectedWallet: moneySourceWidgetBank,
          onWalletSelected: (wallet) {
            selected = wallet;
          },
        ),
      );
      await tester.pump();

      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Bank'), findsOneWidget);
      expect(find.byIcon(Symbols.check_circle_rounded), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'bank');
      await tester.pump();

      expect(find.text('Cash'), findsNothing);
      expect(find.text('Bank'), findsOneWidget);

      await tester.tap(find.text('Bank'));
      await tester.pump();

      expect(selected?.id, 'w2');
    });
  });
}