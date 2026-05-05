import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/loans/widgets/loan_list_item.dart';

import '../../../fixtures/features/loans/loan_widget_fixtures.dart';

void main() {
  group('Loan widgets', () {
    testWidgets('LoanListItem renders loan details', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          locale: const Locale('en'),
          home: Scaffold(
            body: LoanListItem(
              loan: loanWidgetLoan,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Borrow from A'), findsOneWidget);
      expect(find.text('Loan'), findsOneWidget);
      expect(find.textContaining('VND 3,000,000'), findsOneWidget);
      expect(find.textContaining('Date:'), findsOneWidget);
      expect(find.textContaining('Due date:'), findsOneWidget);
      expect(find.text('monthly return'), findsOneWidget);
    });

    testWidgets('LoanListItem delete action invokes callback', (tester) async {
      var deleteCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          locale: const Locale('en'),
          home: Scaffold(
            body: LoanListItem(
              loan: loanWidgetDebt,
              onTap: () {},
              onDelete: () => deleteCount += 1,
            ),
          ),
        ),
      );

      await tester.drag(find.byType(Slidable), const Offset(-400, 0));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Delete'));
      await tester.pump();

      expect(deleteCount, 1);
    });
  });
}