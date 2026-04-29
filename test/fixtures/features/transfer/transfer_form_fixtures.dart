import 'package:zenit/features/transfer/models/money_transfer_model.dart';

final transferFormInitialTransfer = MoneyTransferModel(
  id: 't1',
  fromWalletId: 'w1',
  toWalletId: 'w2',
  amount: 100000,
  transferDate: DateTime.utc(2026, 4, 26),
  note: 'move funds',
);