import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/setting_childs/money_source_manage/forms/add_edit_money_source_form.dart';
import 'package:zenit/l10n/app_localizations.dart';

Widget _buildApp(Widget child) {
  return MaterialApp(
    theme: lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('AddEditMoneySourceForm submits valid data', (tester) async {
    final controller = AddEditMoneySourceFormController();
    AddEditMoneySourceData? submittedData;

    await tester.pumpWidget(
      _buildApp(
        AddEditMoneySourceForm(
          controller: controller,
          onSubmit: (data) {
            submittedData = data;
          },
        ),
      ),
    );

    expect(find.text('Money source name'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Note'), findsOneWidget);
    expect(find.text('Select icon'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Cash');
    await tester.enterText(find.byType(TextFormField).at(1), '1200');
    await tester.enterText(find.byType(TextFormField).at(2), 'Pocket money');
    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.tap(find.byIcon(Symbols.shopping_cart_rounded));
    await tester.pump();

    controller.submit();
    await tester.pumpAndSettle();

    expect(submittedData?.name, 'Cash');
    expect(submittedData?.iconName, 'shopping_cart_rounded');
    expect(submittedData?.amount, 1200);
    expect(submittedData?.note, 'Pocket money');
    expect(submittedData?.isIncludeInTotalBalance, false);
  });
}