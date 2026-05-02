import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';
import 'package:zenit/features/setting_childs/money_source_manage/providers/money_source_provider.dart';
import 'package:zenit/features/transaction/forms/add_transaction_form_prefill_helper.dart';
import 'package:zenit/features/transaction/models/transaction_model.dart';
import 'package:zenit/features/transaction/services/transaction_service.dart';

class MockMoneySourceProvider extends Mock implements MoneySourceProvider {}
class MockCategoryProvider extends Mock implements CategoryProvider {}
class MockTransactionService extends Mock implements TransactionService {}

MoneySourceModel _wallet(String id, String name) {
  return MoneySourceModel(
    id: id,
    name: name,
    amount: 1000000,
    iconName: 'wallet',
    backgroundColorHex: '#FFFFFF',
  );
}

CategoryModel _category(String id, String name, String groupType) {
  return CategoryModel(
    id: id,
    name: name,
    icon: 'icon',
    groupType: groupType,
  );
}

void main() {
  late MockMoneySourceProvider moneySourceProvider;
  late MockCategoryProvider categoryProvider;
  late MockTransactionService transactionService;

  setUp(() {
    moneySourceProvider = MockMoneySourceProvider();
    categoryProvider = MockCategoryProvider();
    transactionService = MockTransactionService();
  });

  group('AddTransactionFormPrefillResult', () {
    test('creates result with null fields', () {
      const result = AddTransactionFormPrefillResult();

      expect(result.wallet, isNull);
      expect(result.category, isNull);
      expect(result.isIncomeTransaction, isNull);
    });
  });

  group('AddTransactionFormPrefillHelper.loadFromRecentTransaction', () {
    test('loads providers and returns empty when wallet list is empty', () async {
      when(() => moneySourceProvider.hasData).thenReturn(false);
      when(() => categoryProvider.hasData).thenReturn(false);
      when(() => moneySourceProvider.loadAllMoneySources()).thenAnswer((_) async {});
      when(() => categoryProvider.loadAllCategories()).thenAnswer((_) async {});
      when(() => moneySourceProvider.moneySources).thenReturn([]);

      final result = await AddTransactionFormPrefillHelper.loadFromRecentTransaction(
        moneySourceProvider: moneySourceProvider,
        categoryProvider: categoryProvider,
        transactionService: transactionService,
      );

      expect(result.wallet, isNull);
      expect(result.category, isNull);
      expect(result.isIncomeTransaction, isNull);
      verify(() => moneySourceProvider.loadAllMoneySources()).called(1);
      verify(() => categoryProvider.loadAllCategories()).called(1);
      verifyNever(() => transactionService.getAllTransactions(
        pageSize: any(named: 'pageSize'),
        useCountTotal: any(named: 'useCountTotal'),
      ));
    });

    test('returns fallback wallet when latest transaction list is empty', () async {
      final wallet = _wallet('w1', 'Main Wallet');
      when(() => moneySourceProvider.hasData).thenReturn(true);
      when(() => categoryProvider.hasData).thenReturn(true);
      when(() => moneySourceProvider.moneySources).thenReturn([wallet]);
      when(() => transactionService.getAllTransactions(
        pageSize: 1,
        useCountTotal: false,
      )).thenAnswer((_) async => TransactionListResponse.fromJson({
            'items': [],
            'meta': {'totalItems': 0, 'pageCount': 0, 'pageSize': 10},
          }));

      final result = await AddTransactionFormPrefillHelper.loadFromRecentTransaction(
        moneySourceProvider: moneySourceProvider,
        categoryProvider: categoryProvider,
        transactionService: transactionService,
      );

      expect(result.wallet, wallet);
      expect(result.category, isNull);
      expect(result.isIncomeTransaction, isNull);
    });

    test('prefills wallet category and income type from latest transaction', () async {
      final wallet = _wallet('w2', 'Backup Wallet');
      final category = _category('c-income', 'Salary', '5');
      when(() => moneySourceProvider.hasData).thenReturn(true);
      when(() => categoryProvider.hasData).thenReturn(true);
      when(() => moneySourceProvider.moneySources).thenReturn([
        _wallet('w1', 'Main Wallet'),
        wallet,
      ]);
      when(() => categoryProvider.findCategoryById('c-income')).thenReturn(category);
      when(() => transactionService.getAllTransactions(
        pageSize: 1,
        useCountTotal: false,
      )).thenAnswer((_) async => TransactionListResponse.fromJson({
            'items': [
              {
                'id': 't1',
                'title': 'Salary',
                'amount': 15000000,
                'transactionDate': '2026-04-30T00:00:00Z',
                'categoryId': 'c-income',
                'walletId': 'w2',
              },
            ],
            'meta': {'totalItems': 1, 'pageCount': 1, 'pageSize': 10},
          }));

      final result = await AddTransactionFormPrefillHelper.loadFromRecentTransaction(
        moneySourceProvider: moneySourceProvider,
        categoryProvider: categoryProvider,
        transactionService: transactionService,
      );

      expect(result.wallet, wallet);
      expect(result.category, category);
      expect(result.isIncomeTransaction, true);
    });

    test('builds category from transaction payload when provider has no match', () async {
      final wallet = _wallet('w1', 'Main Wallet');
      when(() => moneySourceProvider.hasData).thenReturn(true);
      when(() => categoryProvider.hasData).thenReturn(true);
      when(() => moneySourceProvider.moneySources).thenReturn([wallet]);
      when(() => categoryProvider.findCategoryById('c-new')).thenReturn(null);
      when(() => transactionService.getAllTransactions(
        pageSize: 1,
        useCountTotal: false,
      )).thenAnswer((_) async => TransactionListResponse.fromJson({
            'items': [
              {
                'id': 't2',
                'title': 'Lunch',
                'amount': 120000,
                'transactionDate': '2026-04-30T00:00:00Z',
                'categoryId': 'c-new',
                'walletId': 'w1',
                'category': {
                  'id': 'c-new',
                  'name': 'Food',
                  'icon': 'restaurant',
                  'color': '#111111',
                  'backgroundColor': '#EEEEEE',
                  'groupType': 0,
                },
              },
            ],
            'meta': {'totalItems': 1, 'pageCount': 1, 'pageSize': 10},
          }));

      final result = await AddTransactionFormPrefillHelper.loadFromRecentTransaction(
        moneySourceProvider: moneySourceProvider,
        categoryProvider: categoryProvider,
        transactionService: transactionService,
      );

      expect(result.wallet, wallet);
      expect(result.category, isNotNull);
      expect(result.category!.id, 'c-new');
      expect(result.category!.name, 'Food');
      expect(result.category!.groupType, '0');
      expect(result.isIncomeTransaction, false);
    });

    test('uses transaction category id when categoryId is empty', () async {
      final wallet = _wallet('w1', 'Main Wallet');
      when(() => moneySourceProvider.hasData).thenReturn(true);
      when(() => categoryProvider.hasData).thenReturn(true);
      when(() => moneySourceProvider.moneySources).thenReturn([wallet]);
      when(() => categoryProvider.findCategoryById('')).thenReturn(null);
      when(() => transactionService.getAllTransactions(
        pageSize: 1,
        useCountTotal: false,
      )).thenAnswer((_) async => TransactionListResponse.fromJson({
            'items': [
              {
                'id': 't3',
                'title': 'Coffee',
                'amount': 50000,
                'transactionDate': '2026-04-30T00:00:00Z',
                'categoryId': '',
                'walletId': 'w1',
                'category': {
                  'id': 'c-fallback',
                  'name': 'Drink',
                  'icon': 'coffee',
                  'color': '#222222',
                  'backgroundColor': '#DDDDDD',
                  'groupType': 0,
                },
              },
            ],
            'meta': {'totalItems': 1, 'pageCount': 1, 'pageSize': 10},
          }));

      final result = await AddTransactionFormPrefillHelper.loadFromRecentTransaction(
        moneySourceProvider: moneySourceProvider,
        categoryProvider: categoryProvider,
        transactionService: transactionService,
      );

      expect(result.wallet, wallet);
      expect(result.category, isNotNull);
      expect(result.category!.id, 'c-fallback');
      expect(result.category!.name, 'Drink');
      expect(result.isIncomeTransaction, false);
    });

    test('falls back to first wallet when service throws', () async {
      final wallet = _wallet('w1', 'Main Wallet');
      when(() => moneySourceProvider.hasData).thenReturn(true);
      when(() => categoryProvider.hasData).thenReturn(true);
      when(() => moneySourceProvider.moneySources).thenReturn([wallet]);
      when(() => transactionService.getAllTransactions(
        pageSize: 1,
        useCountTotal: false,
      )).thenThrow(Exception('boom'));

      final result = await AddTransactionFormPrefillHelper.loadFromRecentTransaction(
        moneySourceProvider: moneySourceProvider,
        categoryProvider: categoryProvider,
        transactionService: transactionService,
      );

      expect(result.wallet, wallet);
      expect(result.category, isNull);
      expect(result.isIncomeTransaction, isNull);
    });
  });
}
