import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';
import 'package:zenit/features/setting_childs/money_source_manage/providers/money_source_provider.dart';
import 'package:zenit/features/transaction/models/transaction_model.dart';
import 'package:zenit/features/transaction/services/transaction_service.dart';

class AddTransactionFormPrefillResult {
  final MoneySourceModel? wallet;
  final CategoryModel? category;
  final bool? isIncomeTransaction;

  const AddTransactionFormPrefillResult({
    this.wallet,
    this.category,
    this.isIncomeTransaction,
  });
}

class AddTransactionFormPrefillHelper {
  static Future<AddTransactionFormPrefillResult> loadFromRecentTransaction({
    required MoneySourceProvider moneySourceProvider,
    required CategoryProvider categoryProvider,
  }) async {
    if (!moneySourceProvider.hasData) {
      await moneySourceProvider.loadAllMoneySources();
    }

    if (!categoryProvider.hasData) {
      await categoryProvider.loadAllCategories();
    }

    if (moneySourceProvider.moneySources.isEmpty) {
      return const AddTransactionFormPrefillResult();
    }

    final transactionService = TransactionService();
    final fallbackWallet = moneySourceProvider.moneySources.first;

    MoneySourceModel selectedWallet = fallbackWallet;
    CategoryModel? selectedCategory;
    bool? isIncomeTransaction;

    try {
      final response = await transactionService.getAllTransactions(
        pageSize: 1,
        useCountTotal: false,
      );

      if (response.items.isNotEmpty) {
        final latestTransaction = response.items.first;
        selectedWallet =
            _resolveWallet(moneySourceProvider, latestTransaction.walletId) ??
            fallbackWallet;
        selectedCategory = _resolveCategory(
          categoryProvider,
          latestTransaction,
        );
        final groupType = _resolveGroupType(
          latestTransaction,
          selectedCategory,
        );
        isIncomeTransaction = groupType == GroupType.income.value;
      }
    } catch (_) {
      selectedWallet = fallbackWallet;
    }

    return AddTransactionFormPrefillResult(
      wallet: selectedWallet,
      category: selectedCategory,
      isIncomeTransaction: isIncomeTransaction,
    );
  }

  static MoneySourceModel? _resolveWallet(
    MoneySourceProvider moneySourceProvider,
    String walletId,
  ) {
    for (final wallet in moneySourceProvider.moneySources) {
      if (wallet.id == walletId) {
        return wallet;
      }
    }
    return null;
  }

  static CategoryModel? _resolveCategory(
    CategoryProvider categoryProvider,
    TransactionModel transaction,
  ) {
    if (transaction.categoryId.isNotEmpty) {
      final existingCategory = categoryProvider.findCategoryById(
        transaction.categoryId,
      );
      if (existingCategory != null) {
        return existingCategory;
      }
    }

    final transactionCategory = transaction.category;
    if (transactionCategory == null) {
      return null;
    }

    return CategoryModel(
      id: transaction.categoryId.isNotEmpty
          ? transaction.categoryId
          : transactionCategory.id,
      name: transactionCategory.name,
      icon: transactionCategory.icon,
      color: transactionCategory.color,
      backgroundColor: transactionCategory.backgroundColor,
      groupType: transactionCategory.groupType.toString(),
    );
  }

  static int? _resolveGroupType(
    TransactionModel transaction,
    CategoryModel? selectedCategory,
  ) {
    final transactionGroupType = transaction.category?.groupType;
    if (transactionGroupType != null) {
      return transactionGroupType;
    }

    if (selectedCategory != null) {
      return int.tryParse(selectedCategory.groupType);
    }

    return null;
  }
}
