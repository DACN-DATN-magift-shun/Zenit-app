import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/setting_childs/category_manage/forms/add_edit_category_form.dart';
import 'package:zenit/l10n/app_localizations.dart';
import 'package:zenit/core/forms/form_fields/custom_text_form_field.dart';

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
  testWidgets('AddCategoryForm submits valid data', (tester) async {
    final controller = AddCategoryFormController();
    AddCategoryData? submittedData;

    await tester.pumpWidget(
      _buildApp(
        AddCategoryForm(
          groupType: 5,
          groupName: 'Necessary',
          initialIcon: 'shopping_cart_rounded',
          controller: controller,
          onSubmit: (data) {
            submittedData = data;
          },
        ),
      ),
    );

    expect(find.text('Category name'), findsOneWidget);
    expect(find.text('Expense limit'), findsOneWidget);
    expect(find.text('Select icon'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byType(CustomTextFormField).at(0),
        matching: find.byType(TextFormField),
      ),
      'Food',
    );

    await tester.enterText(
      find.descendant(
        of: find.byType(CustomTextFormField).at(1),
        matching: find.byType(TextFormField),
      ),
      '150000',
    );

    final ddCountBefore = find.byType(DropdownButton).evaluate().length;
    print('DropdownButton count before tap: $ddCountBefore');
    if (ddCountBefore == 0) debugDumpApp();
    // Use initial groupType=5 (Income) so no need to open dropdown in tests

    // initialIcon is provided, no need to tap to select it in tests

    controller.submit();
    await tester.pumpAndSettle();

    expect(submittedData?.name, 'Food');
    expect(submittedData?.expenseLimit, 150000);
    expect(submittedData?.icon, 'shopping_cart_rounded');
    expect(submittedData?.groupType, 5);
    expect(submittedData?.color, isNotNull);
    expect(submittedData?.backgroundColor, isNotNull);
  });
}