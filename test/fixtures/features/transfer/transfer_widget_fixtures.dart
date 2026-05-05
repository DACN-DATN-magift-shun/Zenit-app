import 'package:zenit/features/transfer/models/money_transfer_model.dart';

final transferWidgetFromWallet = TransferWalletModel(
  id: 'w1',
  name: 'Cash',
  amount: 1000,
  backgroundColor: '#E3F2FD',
  icon: 'account_balance_wallet_rounded',
  note: 'Pocket',
  isIncludeInTotalBalance: true,
  accountId: 'a1',
);

final transferWidgetToWallet = TransferWalletModel(
  id: 'w2',
  name: 'Bank',
  amount: 2000,
  backgroundColor: '#DDF3EA',
  icon: 'account_balance_rounded',
  note: 'Savings',
  isIncludeInTotalBalance: true,
  accountId: 'a1',
);

final transferWidgetModel = MoneyTransferModel(
  id: 't1',
  fromWalletId: 'w1',
  toWalletId: 'w2',
  amount: 100000,
  transferDate: DateTime.utc(2026, 4, 26),
  note: 'move funds',
  fromWallet: transferWidgetFromWallet,
  toWallet: transferWidgetToWallet,
);

final transferWidgetFallbackModel = MoneyTransferModel(
  id: 't2',
  fromWalletId: 'w3',
  toWalletId: 'w4',
  amount: 50000,
  transferDate: DateTime.utc(2026, 4, 26),
  note: '',
);