import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/features/setting_childs/money_source_manage/providers/money_source_provider.dart';
import 'package:zenit/features/setting_childs/money_source_manage/services/money_source_service.dart';

import '../../../../mocks/features/setting_childs/money_source_manage/money_source_provider_mock_data.dart';

class MockMoneySourceService extends Mock implements MoneySourceService {}

void main() {
  late MockMoneySourceService service;
  late MoneySourceProvider provider;

  setUp(() {
    service = MockMoneySourceService();
    provider = MoneySourceProvider(moneySourceService: service);
  });

  group('MoneySourceProvider', () {
    test('loadAllMoneySources success updates list', () async {
      when(
        () => service.getAllMoneySources(),
      ).thenAnswer((_) async => moneySourceProviderInitialList);

      await provider.loadAllMoneySources();

      expect(provider.moneySources.length, 2);
      expect(provider.errorMessage, isNull);
    });

    test('addMoneySource success creates and reloads from server', () async {
      when(
        () => service.createMoneySource(
          name: 'Card',
          icon: 'credit_card_rounded',
          backgroundColorHex: any(named: 'backgroundColorHex'),
          amount: 500,
          note: '',
          isIncludeInTotalBalance: true,
        ),
      ).thenAnswer((_) async => moneySourceProviderAfterCreateList.last);

      when(
        () => service.getAllMoneySources(),
      ).thenAnswer((_) async => moneySourceProviderAfterCreateList);

      final result = await provider.addMoneySource(
        name: 'Card',
        icon: 'credit_card_rounded',
        amount: 500,
      );

      expect(result, true);
      expect(provider.moneySources.length, 3);
      verify(() => service.getAllMoneySources()).called(1);
    });

    test('updateMoneySource updates item in local state', () async {
      when(
        () => service.getAllMoneySources(),
      ).thenAnswer((_) async => moneySourceProviderInitialList);
      await provider.loadAllMoneySources();

      when(
        () => service.updateMoneySource(
          id: any(named: 'id'),
          name: any(named: 'name'),
          icon: any(named: 'icon'),
          backgroundColorHex: any(named: 'backgroundColorHex'),
          amount: any(named: 'amount'),
          note: any(named: 'note'),
          isIncludeInTotalBalance: any(named: 'isIncludeInTotalBalance'),
        ),
      ).thenAnswer((_) async => moneySourceProviderUpdatedItem);

      final result = await provider.updateMoneySource(
        id: 'w1',
        name: 'Cash Updated',
        icon: 'savings_rounded',
        amount: 999,
      );

      expect(result, true);
      expect(provider.moneySources.firstWhere((e) => e.id == 'w1').name, 'Cash Updated');
    });
  });
}
