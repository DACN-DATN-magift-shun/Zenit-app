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
      expect(provider.isLoading, isFalse);
      expect(provider.hasData, isTrue);
    });

    test('loadTransfers failure captures error state', () async {
      when(
        () => service.getMoneyTransfers(search: '', pageSize: 100),
      ).thenThrow(Exception('load failed'));

      await provider.loadTransfers();

      expect(provider.transfers, isEmpty);
      expect(provider.errorMessage, contains('load failed'));
      expect(provider.isLoading, isFalse);
      expect(provider.hasData, isFalse);
    });

    test('setSearchKeyword trims and reloads', () async {
      when(
        () => service.getMoneyTransfers(search: 'abc', pageSize: 100),
      ).thenAnswer((_) async => moneyTransferProviderListResponse);

      await provider.setSearchKeyword('  abc  ');

      expect(provider.searchKeyword, 'abc');
      verify(() => service.getMoneyTransfers(search: 'abc', pageSize: 100)).called(1);
    });

    test('refreshTransfers uses current search keyword', () async {
      when(
        () => service.getMoneyTransfers(search: 'abc', pageSize: 100),
      ).thenAnswer((_) async => moneyTransferProviderListResponse);

      await provider.loadTransfers(search: ' abc ');
      await provider.refreshTransfers();

      verify(() => service.getMoneyTransfers(search: 'abc', pageSize: 100)).called(2);
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
      expect(provider.isActionLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('addTransfer failure records error state', () async {
      final transferDate = DateTime.parse('2026-04-12T00:00:00Z');

      when(
        () => service.createMoneyTransfer(
          fromWalletId: 'w1',
          toWalletId: 'w3',
          amount: 10,
          transferDate: transferDate,
          note: '',
        ),
      ).thenThrow(Exception('create failed'));

      final result = await provider.addTransfer(
        fromWalletId: 'w1',
        toWalletId: 'w3',
        amount: 10,
        transferDate: transferDate,
      );

      expect(result, false);
      expect(provider.errorMessage, contains('create failed'));
      expect(provider.isActionLoading, isFalse);
    });

    test('updateTransfer success refreshes list', () async {
      final transferDate = DateTime.parse('2026-04-12T00:00:00Z');

      when(
        () => service.updateMoneyTransfer(
          id: 't1',
          fromWalletId: 'w1',
          toWalletId: 'w3',
          amount: 10,
          transferDate: transferDate,
          note: 'updated',
        ),
      ).thenAnswer((_) async => moneyTransferProviderAfterCreate.last);

      when(
        () => service.getMoneyTransfers(search: '', pageSize: 100),
      ).thenAnswer((_) async => moneyTransferProviderAfterCreateResponse);

      final result = await provider.updateTransfer(
        id: 't1',
        fromWalletId: 'w1',
        toWalletId: 'w3',
        amount: 10,
        transferDate: transferDate,
        note: 'updated',
      );

      expect(result, true);
      expect(provider.transfers.length, 3);
      expect(provider.isActionLoading, isFalse);
    });

    test('updateTransfer failure records error state', () async {
      final transferDate = DateTime.parse('2026-04-12T00:00:00Z');

      when(
        () => service.updateMoneyTransfer(
          id: 't1',
          fromWalletId: 'w1',
          toWalletId: 'w3',
          amount: 10,
          transferDate: transferDate,
          note: 'updated',
        ),
      ).thenThrow(Exception('update failed'));

      final result = await provider.updateTransfer(
        id: 't1',
        fromWalletId: 'w1',
        toWalletId: 'w3',
        amount: 10,
        transferDate: transferDate,
        note: 'updated',
      );

      expect(result, false);
      expect(provider.errorMessage, contains('update failed'));
      expect(provider.isActionLoading, isFalse);
    });

    test('deleteTransfer removes item on success', () async {
      when(() => service.deleteMoneyTransfer('t1')).thenAnswer((_) async => true);

      final result = await provider.deleteTransfer('t1');

      expect(result, isTrue);
      expect(provider.transfers.any((item) => item.id == 't1'), isFalse);
      expect(provider.isActionLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('deleteTransfer failure records error state', () async {
      when(() => service.deleteMoneyTransfer('t1')).thenThrow(Exception('delete failed'));

      final result = await provider.deleteTransfer('t1');

      expect(result, isFalse);
      expect(provider.errorMessage, contains('delete failed'));
      expect(provider.isActionLoading, isFalse);
    });
  });
}
