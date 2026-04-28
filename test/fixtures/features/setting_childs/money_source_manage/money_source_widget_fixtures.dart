import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';

final moneySourceWidgetCash = MoneySourceModel(
  id: 'w1',
  name: 'Cash',
  amount: 1200,
  iconName: 'account_balance_wallet_rounded',
  backgroundColorHex: '#E3F2FD',
  note: 'Pocket money',
);

final moneySourceWidgetBank = MoneySourceModel(
  id: 'w2',
  name: 'Bank',
  amount: 3000000,
  iconName: 'account_balance_rounded',
  backgroundColorHex: '#DDEEFF',
  note: '',
);

List<MoneySourceModel> buildMoneySourceWidgetList() {
  return <MoneySourceModel>[
    moneySourceWidgetCash,
    moneySourceWidgetBank,
  ];
}