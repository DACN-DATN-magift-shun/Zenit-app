import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/features/transfer/providers/money_transfer_provider.dart';
import 'package:zenit/features/transfer/services/money_transfer_service.dart';

import '../../../mocks/features/transfer/money_transfer_provider_mock_data.dart';

class MockMoneyTransferService extends Mock implements MoneyTransferService {}

void main() {
  late MockMoneyTransferService service;
  late MoneyTransferProvider provider;

  setUp(() {
    service = MockMoneyTransferService();
    provider = MoneyTransferProvider(moneyTransferService: service);
  });

  group('MoneyTransferProvider', () {
    test('loadTransfers success updates transfers list', () async {
      when(
        () => service.getMoneyTransfers(search: '', pageSize: 100),
      ).thenAnswer((_) async => moneyTransferProviderListResponse);

      await provider.loadTransfers();

      expect(provider.transfers.length, 2);
      expect(provider.errorMessage, isNull);
    });

    test('setSearchKeyword trims and reloads', () async {
      when(
        () => service.getMoneyTransfers(search: 'abc', pageSize: 100),
      ).thenAnswer((_) async => moneyTransferProviderListResponse);

      await provider.setSearchKeyword('  abc  ');

      expect(provider.searchKeyword, 'abc');
      verify(() => service.getMoneyTransfers(search: 'abc', pageSize: 100)).called(1);
    });

    test('addTransfer success refreshes list', () async {
      final transferDate = DateTime.parse('2026-04-12T00:00:00Z');

      when(
        () => service.createMoneyTransfer(
          fromWalletId: 'w1',
          toWalletId: 'w3',
          amount: 10,
          transferDate: transferDate,
          note: '',
        ),
      ).thenAnswer((_) async => moneyTransferProviderAfterCreate.last);

      when(
        () => service.getMoneyTransfers(search: '', pageSize: 100),
      ).thenAnswer((_) async => moneyTransferProviderAfterCreateResponse);

      final result = await provider.addTransfer(
        fromWalletId: 'w1',
        toWalletId: 'w3',
        amount: 10,
        transferDate: transferDate,
      );

      expect(result, true);
      expect(provider.transfers.length, 3);
    });
  });
}
