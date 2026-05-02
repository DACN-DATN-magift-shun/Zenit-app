import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/providers/locale_provider.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';
import 'package:zenit/features/setting_childs/money_source_manage/providers/money_source_provider.dart';
import 'package:zenit/features/transaction/forms/add_transaction_form.dart';
import 'package:zenit/features/transaction/forms/add_transaction_form_prefill_helper.dart';
import 'package:zenit/l10n/app_localizations.dart';

class MockCategoryProvider extends Mock implements CategoryProvider {}
class MockMoneySourceProvider extends Mock implements MoneySourceProvider {}
class MockLocaleProvider extends Mock implements LocaleProvider {}

final expenseCategory = CategoryModel(
  id: 'cat-expense',
  name: 'Food',
  icon: 'restaurant',
  groupType: '0',
  backgroundColor: '#FF5733',
);

final incomeCategory = CategoryModel(
  id: 'cat-income',
  name: 'Salary',
  icon: 'salary',
  groupType: '5',
  backgroundColor: '#33FF57',
);

final testWallet1 = MoneySourceModel(
  id: 'wallet-1',
  name: 'Main Wallet',
  amount: 5000000,
  iconName: 'wallet',
  backgroundColorHex: '#FF5733',
  note: 'Main account',
  isIncludeInTotalBalance: true,
);

final testWallet2 = MoneySourceModel(
  id: 'wallet-2',
  name: 'Backup Wallet',
  amount: 2500000,
  iconName: 'wallet',
  backgroundColorHex: '#33AAFF',
  note: 'Backup account',
  isIncludeInTotalBalance: true,
);

Widget _buildApp(
  Widget child, {
  List<MoneySourceModel>? wallets,
  List<CategoryModel>? categories,
  Future<AddTransactionFormPrefillResult> Function(
    MoneySourceProvider moneySourceProvider,
    CategoryProvider categoryProvider,
  )? prefillLoader,
}) {
  wallets ??= [testWallet1];
  categories ??= [expenseCategory, incomeCategory];

  final moneySourceProvider = MockMoneySourceProvider();
  final categoryProvider = MockCategoryProvider();
  final localeProvider = MockLocaleProvider();

  when(() => moneySourceProvider.moneySources).thenReturn(wallets);
  when(() => moneySourceProvider.hasData).thenReturn(true);
  when(() => moneySourceProvider.isLoading).thenReturn(false);
  when(() => moneySourceProvider.isActionLoading).thenReturn(false);
  when(() => moneySourceProvider.errorMessage).thenReturn(null);
  when(() => moneySourceProvider.refreshMoneySources()).thenAnswer((_) async {});
  when(() => moneySourceProvider.loadAllMoneySources()).thenAnswer((_) async {});

  when(() => categoryProvider.categories).thenReturn(categories);
  when(() => categoryProvider.hasData).thenReturn(true);
  when(() => categoryProvider.isLoading).thenReturn(false);
  when(() => categoryProvider.errorMessage).thenReturn(null);
  when(() => categoryProvider.refreshCategories()).thenAnswer((_) async {});
  when(() => categoryProvider.loadAllCategories()).thenAnswer((_) async {});
  when(() => categoryProvider.findCategoryById(any())).thenReturn(null);

  when(() => localeProvider.locale).thenReturn(const Locale('en'));

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<MoneySourceProvider>.value(
        value: moneySourceProvider,
      ),
      ChangeNotifierProvider<CategoryProvider>.value(
        value: categoryProvider,
      ),
      ChangeNotifierProvider<LocaleProvider>.value(
        value: localeProvider,
      ),
    ],
    child: MaterialApp(
      theme: lightTheme,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: AddTransactionForm(
          prefillLoader: prefillLoader,
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(MoneySourceModel(
      id: '',
      name: '',
      amount: 0,
      iconName: 'wallet',
      backgroundColorHex: '#FFFFFF',
      note: '',
      isIncludeInTotalBalance: true,
    ));
  });

  group('AddTransactionForm - Prefill and submit', () {
    testWidgets('toggles collect later and shows loan summary', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          const AddTransactionForm(),
          prefillLoader: (_, __) async => AddTransactionFormPrefillResult(
            wallet: testWallet1,
            category: expenseCategory,
            isIncomeTransaction: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('transaction-amount-field')),
        '100000',
      );
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('transaction-loan-amount-field')),
          findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('transaction-loan-amount-field')),
        '40000',
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('transaction-loan-amount-field')),
          findsOneWidget);
    });

    testWidgets('clears incompatible income category when collect later is enabled',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(
          const AddTransactionForm(),
          prefillLoader: (_, __) async => AddTransactionFormPrefillResult(
            wallet: testWallet1,
            category: incomeCategory,
            isIncomeTransaction: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Salary'), findsOneWidget);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(find.text('Salary'), findsNothing);
      expect(find.text('Select'), findsOneWidget);
    });

    testWidgets('cycles wallet on horizontal swipe', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          const AddTransactionForm(),
          wallets: [testWallet1, testWallet2],
          prefillLoader: (_, __) async => AddTransactionFormPrefillResult(
            wallet: testWallet1,
            category: expenseCategory,
            isIncomeTransaction: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Main Wallet'), findsOneWidget);
      expect(find.text('Backup Wallet'), findsNothing);

      await tester.fling(
        find.byKey(const ValueKey('wallet-1')),
        const Offset(-300, 0),
        2000,
      );
      await tester.pumpAndSettle();

      expect(find.text('Backup Wallet'), findsOneWidget);
    });

    testWidgets('formats amount expressions with equals sign', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          const AddTransactionForm(),
          prefillLoader: (_, __) async => AddTransactionFormPrefillResult(
            wallet: testWallet1,
            category: expenseCategory,
            isIncomeTransaction: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final amountField = find.byKey(const ValueKey('transaction-amount-field'));
      await tester.enterText(amountField, '100+50=');
      await tester.pumpAndSettle();

      final textField = tester.widget<TextFormField>(amountField);
      expect(textField.controller?.text, '150');
    });
  });
}
