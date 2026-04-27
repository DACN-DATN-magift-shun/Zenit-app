import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';
import '../../../../mocks/features/setting_childs/money_source_manage/money_source_model_mock_data.dart';
import '../../../../mocks/json_source_mock.dart';

void main() {
  group('MoneySourceModel', () {
    test('fromJson resolves wallet id aliases and bool string', () {
      final source = MockJsonSource();
      when(() => source.value).thenReturn(moneySourceFromJsonMockData);

      final model = MoneySourceModel.fromJson(source.value);

      expect(model.id, 'w1');
      expect(model.amount, 1200);
      expect(model.isIncludeInTotalBalance, false);
      expect(model.iconData, Symbols.savings_rounded);
    });

    test('toCreateJson does not include id', () {
      const model = MoneySourceModel(
        id: 'w2',
        name: 'Wallet',
        amount: 10,
        iconName: 'credit_card_rounded',
        backgroundColorHex: '#E3F2FD',
      );

      final json = model.toCreateJson();

      expect(json.containsKey('id'), false);
      expect(json['name'], 'Wallet');
    });

    test('copyWith updates selected properties', () {
      const model = MoneySourceModel(
        id: 'w3',
        name: 'Old',
        amount: 1,
        iconName: 'credit_card_rounded',
        backgroundColorHex: '#E3F2FD',
      );

      final copied = model.copyWith(name: 'New', amount: 99);

      expect(copied.name, 'New');
      expect(copied.amount, 99);
      expect(copied.id, 'w3');
    });

    test('MoneySourceIconMapper returns default for unknown icon name', () {
      expect(
        MoneySourceIconMapper.fromName('unknown_icon_name'),
        Symbols.account_balance_wallet_rounded,
      );
    });
  });
}
