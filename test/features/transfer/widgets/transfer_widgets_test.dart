import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/transfer/widgets/transfer_list_item.dart';

import '../../../fixtures/features/transfer/transfer_widget_fixtures.dart';

void main() {
  group('Transfer widgets', () {
    testWidgets('TransferListItem renders transfer details', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          locale: const Locale('en'),
          home: Scaffold(
            body: TransferListItem(
              transfer: transferWidgetModel,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Cash → Bank'), findsOneWidget);
      expect(find.text('move funds'), findsOneWidget);
      expect(find.textContaining('100.000đ'), findsOneWidget);
      expect(find.textContaining('26/04/2026'), findsOneWidget);
    });

    testWidgets('TransferListItem shows fallback labels when wallets missing', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          locale: const Locale('en'),
          home: Scaffold(
            body: TransferListItem(
              transfer: transferWidgetFallbackModel,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('From wallet → To wallet'), findsOneWidget);
      expect(find.text('Wallet to wallet transfer'), findsOneWidget);
    });

    testWidgets('TransferListItem delete action invokes callback', (
      tester,
    ) async {
      var deleteCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          locale: const Locale('en'),
          home: Scaffold(
            body: TransferListItem(
              transfer: transferWidgetModel,
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