import 'package:zenit/features/transaction/models/transaction_model.dart';

final transactionFormCategory = TransactionCategoryModel(
  id: 'c1',
  name: 'Food',
  icon: 'restaurant',
  color: '#111111',
  backgroundColor: '#EEEEEE',
  groupType: 0,
);

final transactionFormInitialTransaction = TransactionModel(
  id: 'tx1',
  title: 'Lunch',
  note: 'team meal',
  amount: 120000,
  transactionDate: DateTime.utc(2026, 4, 25, 12),
  categoryId: 'c1',
  walletId: 'w1',
  category: transactionFormCategory,
);