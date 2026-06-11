import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/loans/models/loan_model.dart';
import 'package:zenit/features/loans/forms/add_edit_loan_form.dart';
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
  testWidgets('AddEditLoanForm submits valid data', (tester) async {
    final controller = AddEditLoanFormController();
    LoanFormData? submittedData;

    await tester.pumpWidget(
      _buildApp(
        AddEditLoanForm(
          controller: controller,
          onSubmit: (data) async {
            submittedData = data;
          },
        ),
      ),
    );

    expect(find.text('Loan / debt name'), findsOneWidget);
    expect(find.text('Type'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Due date'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Borrow from A');
    await tester.tap(find.text('Debt'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(1), '3000000');
    await tester.enterText(find.byType(TextFormField).at(2), 'monthly return');

    await controller.submit();
    await tester.pumpAndSettle();

    expect(submittedData?.name, 'Borrow from A');
    expect(submittedData?.type, 1);
    expect(submittedData?.amount, 3000000);
    expect(submittedData?.note, 'monthly return');
    expect(submittedData?.date, isA<DateTime>());
    expect(submittedData?.dueDate, isA<DateTime>());
  });

  testWidgets('AddEditLoanForm prefills edit mode values', (tester) async {
    final initialLoan = LoanModel(
      id: 'loan-1',
      name: 'Borrow from A',
      type: 1,
      amount: 3000000,
      date: DateTime.utc(2026, 4, 1),
      dueDate: DateTime.utc(2026, 5, 1),
      note: 'monthly return',
    );

    await tester.pumpWidget(
      _buildApp(
        AddEditLoanForm(
          initialLoan: initialLoan,
          onSubmit: (_) async {},
        ),
      ),
    );

    expect(find.text('Borrow from A'), findsOneWidget);
    expect(find.text('Debt'), findsOneWidget);
    expect(find.text('3000000'), findsOneWidget);
    expect(find.text('monthly return'), findsOneWidget);

    final segmentedButton = tester.widget<SegmentedButton<int>>(
      find.byType(SegmentedButton<int>).last,
    );
    expect(segmentedButton.selected, {1});
  });
}