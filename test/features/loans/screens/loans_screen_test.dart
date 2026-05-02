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
  Future<List<LoanModel>> getLoans({
    int? type,
    String? search,
    String? beforeId,
    int pageSize = 100,
    bool useCountTotal = false,
  }) async {
    return [
      LoanModel(
        id: 'l-1',
        name: 'Pay rent',
        type: 0,
        amount: 5000000,
        date: DateTime(2026, 4, 1),
        dueDate: DateTime(2026, 6, 1),
        note: 'monthly return',
      ),
      LoanModel(
        id: 'l-2',
        name: 'Debt to friend',
        type: 1,
        amount: 2500000,
        date: DateTime(2026, 4, 2),
        dueDate: DateTime(2026, 7, 1),
        note: 'split bill',
      ),
    ];
  }
}

class FakeLoansProvider extends LoansProvider {
  FakeLoansProvider({
    List<LoanModel> initialLoans = const <LoanModel>[],
    bool isLoading = false,
    String? errorMessage,
    bool keepLoadingOnLoad = false,
  }) : super(loansService: FakeLoansService()) {
    _loans = List<LoanModel>.of(initialLoans);
    _isLoading = isLoading;
    _errorMessage = errorMessage;
    _keepLoadingOnLoad = keepLoadingOnLoad;
  }

  List<LoanModel> _loans = const <LoanModel>[];
  bool _isLoading = false;
  String? _errorMessage;
  bool _keepLoadingOnLoad = false;
  int? _selectedTypeFilter;
  String _searchKeyword = '';

  int loadLoansCalls = 0;
  int refreshLoansCalls = 0;
  int setSearchKeywordCalls = 0;
  int setTypeFilterCalls = 0;

  @override
  List<LoanModel> get loans => _loans;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  int? get selectedTypeFilter => _selectedTypeFilter;

  @override
  String get searchKeyword => _searchKeyword;

  @override
  bool get hasData => _loans.isNotEmpty;

  @override
  int get totalLoanAmount => _loans.where((item) => item.type == 0).fold(0, (sum, item) => sum + item.amount);

  @override
  int get totalDebtAmount => _loans.where((item) => item.type == 1).fold(0, (sum, item) => sum + item.amount);

  @override
  int get netBalance => totalLoanAmount - totalDebtAmount;

  @override
  Future<void> loadLoans({int? type, String? search, int pageSize = 100}) async {
    loadLoansCalls += 1;
    _selectedTypeFilter = type;
    _searchKeyword = search ?? _searchKeyword;
    if (!_keepLoadingOnLoad) {
      _isLoading = false;
    }
    notifyListeners();
  }

  @override
  Future<void> refreshLoans() async {
    refreshLoansCalls += 1;
  }

  @override
  Future<void> setSearchKeyword(String keyword) async {
    setSearchKeywordCalls += 1;
    _searchKeyword = keyword.trim();
    notifyListeners();
  }

  @override
  Future<void> setTypeFilter(int? type) async {
    setTypeFilterCalls += 1;
    _selectedTypeFilter = type;
    notifyListeners();
  }
}

Widget _buildApp(Widget child, LoansProvider provider, {Locale locale = const Locale('en')}) {
  return ChangeNotifierProvider(
    create: (_) => LocaleProvider(),
    child: MaterialApp(
      theme: lightTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChangeNotifierProvider<LoansProvider>.value(
        value: provider,
        child: child,
      ),
    ),
  );
}

void main() {
  testWidgets('LoansScreen shows loading state', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        const Scaffold(body: LoansScreen()),
        FakeLoansProvider(isLoading: true, keepLoadingOnLoad: true),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('LoansScreen shows error state', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        const Scaffold(body: LoansScreen()),
        FakeLoansProvider(errorMessage: 'boom'),
      ),
    );

    await tester.pump();

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('boom'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('LoansScreen shows empty state and search clear branch', (tester) async {
    final provider = FakeLoansProvider();

    await tester.pumpWidget(
      _buildApp(const Scaffold(body: LoansScreen()), provider),
    );

    await tester.pump();

    expect(find.text('No loans or debts yet'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  rent  ');
    await tester.pump();

    expect(find.byIcon(Icons.close), findsAtLeastNWidgets(1));

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pump();

    expect(provider.setSearchKeywordCalls, 2);
    expect(provider.searchKeyword, isEmpty);
  });

  testWidgets('LoansScreen shows summary, filters and opens add drawer', (tester) async {
    final provider = FakeLoansProvider(
      initialLoans: [
        LoanModel(
          id: 'l-1',
          name: 'Pay rent',
          type: 0,
          amount: 5000000,
          date: DateTime(2026, 4, 1),
          dueDate: DateTime(2026, 6, 1),
          note: 'monthly return',
        ),
        LoanModel(
          id: 'l-2',
          name: 'Debt to friend',
          type: 1,
          amount: 2500000,
          date: DateTime(2026, 4, 2),
          dueDate: DateTime(2026, 7, 1),
          note: 'split bill',
        ),
      ],
    );

    await tester.pumpWidget(
      _buildApp(const Scaffold(body: LoansScreen()), provider),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Loans'), findsWidgets);
    expect(find.text('Pay rent'), findsOneWidget);
    expect(find.text('Debt to friend'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Loans'));
    await tester.pump();
    expect(provider.setTypeFilterCalls, 1);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Add loan/debt'), findsOneWidget);
  });

  testWidgets('LoansScreen opens edit drawer from list item', (tester) async {
    final provider = FakeLoansProvider(
      initialLoans: [
        LoanModel(
          id: 'l-1',
          name: 'Pay rent',
          type: 0,
          amount: 5000000,
          date: DateTime(2026, 4, 1),
          dueDate: DateTime(2026, 6, 1),
          note: 'monthly return',
        ),
      ],
    );

    await tester.pumpWidget(
      _buildApp(const Scaffold(body: LoansScreen()), provider),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Pay rent'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Update loan/debt'), findsOneWidget);
  });
}
