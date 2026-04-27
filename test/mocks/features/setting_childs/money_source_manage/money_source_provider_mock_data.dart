import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';

final moneySourceProviderInitialList = <MoneySourceModel>[
  MoneySourceModel(
    id: 'w1',
    name: 'Cash',
    amount: 100,
    iconName: 'account_balance_wallet_rounded',
    backgroundColorHex: '#E3F2FD',
  ),
  MoneySourceModel(
    id: 'w2',
    name: 'Bank',
    amount: 300,
    iconName: 'account_balance_rounded',
    backgroundColorHex: '#E3F2FD',
  ),
];

final moneySourceProviderAfterCreateList = <MoneySourceModel>[
  ...moneySourceProviderInitialList,
  MoneySourceModel(
    id: 'w3',
    name: 'Card',
    amount: 500,
    iconName: 'credit_card_rounded',
    backgroundColorHex: '#E3F2FD',
  ),
];

const moneySourceProviderUpdatedItem = MoneySourceModel(
  id: 'w1',
  name: 'Cash Updated',
  amount: 999,
  iconName: 'savings_rounded',
  backgroundColorHex: '#E3F2FD',
);
