import 'package:zenit/features/transfer/models/money_transfer_model.dart';

final moneyTransferProviderList = <MoneyTransferModel>[
  MoneyTransferModel(
    id: 't1',
    fromWalletId: 'w1',
    toWalletId: 'w2',
    amount: 100,
    transferDate: DateTime.parse('2026-04-10T00:00:00Z'),
    note: 'move',
  ),
  MoneyTransferModel(
    id: 't2',
    fromWalletId: 'w2',
    toWalletId: 'w3',
    amount: 50,
    transferDate: DateTime.parse('2026-04-11T00:00:00Z'),
    note: 'topup',
  ),
];

final moneyTransferProviderAfterCreate = <MoneyTransferModel>[
  ...moneyTransferProviderList,
  MoneyTransferModel(
    id: 't3',
    fromWalletId: 'w1',
    toWalletId: 'w3',
    amount: 10,
    transferDate: DateTime.parse('2026-04-12T00:00:00Z'),
    note: '',
  ),
];

final moneyTransferProviderListResponse = MoneyTransferListResponse(
  items: moneyTransferProviderList,
  meta: const MoneyTransferMetaModel(
    totalItems: 2,
    pageCount: 1,
    page: 1,
    pageSize: 100,
  ),
);

final moneyTransferProviderAfterCreateResponse = MoneyTransferListResponse(
  items: moneyTransferProviderAfterCreate,
  meta: const MoneyTransferMetaModel(
    totalItems: 3,
    pageCount: 1,
    page: 1,
    pageSize: 100,
  ),
);
