import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/providers/locale_provider.dart';
import 'package:zenit/features/loans/screen/loans_screen.dart';
import 'package:zenit/features/loans/providers/loans_provider.dart';
import 'package:zenit/features/loans/models/loan_model.dart';
import 'package:zenit/features/loans/services/loans_service.dart';
import 'package:zenit/l10n/app_localizations.dart';

class FakeLoansService extends LoansService {
  FakeLoansService() : super();

  @override
  Future<List<LoanModel>> getLoans({int? type, String? search, String? beforeId, int pageSize = 100, bool useCountTotal = false}) async {
    return [
      LoanModel(
        id: 'l-1',
        name: 'Pay rent',
        type: 0,
        amount: 500,
        date: DateTime.now(),
        dueDate: DateTime.now(),
        note: '',
      ),
    ];
  }
}

void main() {
  testWidgets('LoansScreen renders and shows summary', (tester) async {
    final provider = LoansProvider(loansService: FakeLoansService());

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: MaterialApp(
          theme: lightTheme,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChangeNotifierProvider<LoansProvider>.value(
            value: provider,
            child: const Scaffold(body: LoansScreen()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Loans'), findsWidgets);
  });

  testWidgets('LoansScreen shows list item and add button', (tester) async {
    final provider = LoansProvider(loansService: FakeLoansService());

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: MaterialApp(
          theme: lightTheme,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChangeNotifierProvider<LoansProvider>.value(
            value: provider,
            child: const Scaffold(body: LoansScreen()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pay rent'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
