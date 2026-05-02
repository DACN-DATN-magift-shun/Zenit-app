import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/setting_childs/money_source_manage/services/money_source_service.dart';

import '../../../../mocks/features/setting_childs/money_source_manage/services/money_source_service_mock_data.dart';
import '../../../../mocks/network/api_client_mocks.dart';

void main() {
  late MockApiClient apiClient;
  late MoneySourceService service;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    apiClient = MockApiClient();
    service = MoneySourceService(apiClient: apiClient);
  });

  group('MoneySourceService - getAllMoneySources', () {
    test('parses wallets list format', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.wallets,
          queryParameters: const {'PageSize': 100},
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: walletsListResponseData));

      final result = await service.getAllMoneySources();

      expect(result.length, 1);
      expect(result.first.id, 'w1');
      expect(result.first.name, 'Cash');
      expect(result.first.amount, 100000);
    });

    test('parses items format', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.wallets,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: walletsListItemsFormat));

      final result = await service.getAllMoneySources();

      expect(result.length, 1);
      expect(result.first.id, 'w2');
      expect(result.first.name, 'Debit Card');
    });

    test('parses nested data.items format', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.wallets,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: walletsListNestedDataFormat));

      final result = await service.getAllMoneySources();

      expect(result.length, 1);
      expect(result.first.id, 'w3');
      expect(result.first.name, 'Savings');
    });

    test('parses multiple wallets', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.wallets,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: walletsListMultipleData));

      final result = await service.getAllMoneySources();

      expect(result.length, 3);
      expect(result[0].id, 'w1');
      expect(result[1].id, 'w2');
      expect(result[2].id, 'w3');
      expect(result[2].amount, 50000000);
    });

    test('returns empty list when no wallets available', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.wallets,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: walletsEmptyList));

      final result = await service.getAllMoneySources();

      expect(result.isEmpty, true);
    });

    test('throws on non-200 status', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.wallets,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 500, data: {'error': 'Server error'}));

      expect(
        () => service.getAllMoneySources(),
        throwsException,
      );
    });

    test('throws on connection timeout', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.wallets,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(
        () => service.getAllMoneySources(),
        throwsException,
      );
    });

    test('throws on receive timeout', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.wallets,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(DioException(
        type: DioExceptionType.receiveTimeout,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(
        () => service.getAllMoneySources(),
        throwsException,
      );
    });
  });

  group('MoneySourceService - getMoneySourceById', () {
    test('fetches wallet by id', () async {
      when(
        () => apiClient.get(ApiEndpoints.walletById('w1')),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: singleWalletData));

      final result = await service.getMoneySourceById('w1');

      expect(result.id, 'w1');
      expect(result.name, 'Cash');
      expect(result.amount, 100000);
      expect(result.note, 'Personal cash');
      verify(() => apiClient.get(ApiEndpoints.walletById('w1'))).called(1);
    });

    test('throws on non-200 status', () async {
      when(
        () => apiClient.get(ApiEndpoints.walletById('w_invalid')),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 404, data: {'error': 'Not found'}));

      expect(
        () => service.getMoneySourceById('w_invalid'),
        throwsException,
      );
    });

    test('throws on DioException', () async {
      when(
        () => apiClient.get(ApiEndpoints.walletById('w1')),
      ).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      ));

      expect(
        () => service.getMoneySourceById('w1'),
        throwsException,
      );
    });
  });

  group('MoneySourceService - createMoneySource', () {
    test('creates wallet with all parameters', () async {
      when(
        () => apiClient.post(
          ApiEndpoints.createWallet,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 201, data: createWalletResponse));

      final result = await service.createMoneySource(
        name: 'New Wallet',
        icon: 'wallet',
        backgroundColorHex: '#FFEBEE',
        amount: 0,
        note: '',
        isIncludeInTotalBalance: true,
      );

      expect(result.id, 'w_new');
      expect(result.name, 'New Wallet');
      verify(
        () => apiClient.post(
          ApiEndpoints.createWallet,
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test('creates wallet with minimum parameters', () async {
      when(
        () => apiClient.post(
          ApiEndpoints.createWallet,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: createWalletResponse));

      final result = await service.createMoneySource(
        name: 'New Wallet',
        icon: 'wallet',
        backgroundColorHex: '#FFEBEE',
      );

      expect(result.id, 'w_new');
    });

    test('handles 204 status with empty response', () async {
      when(
        () => apiClient.post(
          ApiEndpoints.createWallet,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 204, data: createWalletEmptyResponse));

      final result = await service.createMoneySource(
        name: 'New Wallet',
        icon: 'wallet',
        backgroundColorHex: '#FFEBEE',
      );

      expect(result.name, 'New Wallet');
      expect(result.id, '');
    });

    test('throws on non-2xx status', () async {
      when(
        () => apiClient.post(
          ApiEndpoints.createWallet,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 400, data: {'error': 'Invalid'}));

      expect(
        () => service.createMoneySource(
          name: 'Test',
          icon: 'wallet',
          backgroundColorHex: '#FFFFFF',
        ),
        throwsException,
      );
    });

    test('throws on DioException', () async {
      when(
        () => apiClient.post(
          ApiEndpoints.createWallet,
          data: any(named: 'data'),
        ),
      ).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(
        () => service.createMoneySource(
          name: 'Test',
          icon: 'wallet',
          backgroundColorHex: '#FFFFFF',
        ),
        throwsException,
      );
    });
  });

  group('MoneySourceService - updateMoneySource', () {
    test('updates wallet successfully', () async {
      when(
        () => apiClient.patch(
          ApiEndpoints.updateWalletUrl('w1'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: updateWalletResponse));

      final result = await service.updateMoneySource(
        id: 'w1',
        name: 'Cash Updated',
        icon: 'account_balance_wallet_rounded',
        backgroundColorHex: '#E3F2FD',
        amount: 500000,
      );

      expect(result.id, 'w1');
      expect(result.name, 'Cash Updated');
      expect(result.amount, 500000);
    });

    test('updates wallet with all fields', () async {
      when(
        () => apiClient.patch(
          ApiEndpoints.updateWalletUrl('w1'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: updateWalletResponse));

      final result = await service.updateMoneySource(
        id: 'w1',
        name: 'Cash Updated',
        icon: 'wallet',
        backgroundColorHex: '#FFFFFF',
        amount: 1000000,
        note: 'Updated note',
        isIncludeInTotalBalance: false,
      );

      expect(result.id, 'w1');
      verify(
        () => apiClient.patch(
          ApiEndpoints.updateWalletUrl('w1'),
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test('throws on non-200 status', () async {
      when(
        () => apiClient.patch(
          ApiEndpoints.updateWalletUrl('w1'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 400, data: {'error': 'Invalid'}));

      expect(
        () => service.updateMoneySource(
          id: 'w1',
          name: 'Cash',
          icon: 'wallet',
          backgroundColorHex: '#FFFFFF',
        ),
        throwsException,
      );
    });

    test('throws on DioException', () async {
      when(
        () => apiClient.patch(
          ApiEndpoints.updateWalletUrl('w1'),
          data: any(named: 'data'),
        ),
      ).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(
        () => service.updateMoneySource(
          id: 'w1',
          name: 'Cash',
          icon: 'wallet',
          backgroundColorHex: '#FFFFFF',
        ),
        throwsException,
      );
    });
  });

  group('MoneySourceService - deleteMoneySource', () {
    test('deletes wallet and returns true on 200', () async {
      when(
        () => apiClient.delete(ApiEndpoints.deleteWalletUrl('w1')),
      ).thenAnswer((_) async => buildResponse(statusCode: 200));

      final result = await service.deleteMoneySource('w1');

      expect(result, true);
      verify(() => apiClient.delete(ApiEndpoints.deleteWalletUrl('w1')))
          .called(1);
    });

    test('returns true on 202 Accepted', () async {
      when(
        () => apiClient.delete(ApiEndpoints.deleteWalletUrl('w1')),
      ).thenAnswer((_) async => buildResponse(statusCode: 202));

      final result = await service.deleteMoneySource('w1');

      expect(result, true);
    });

    test('returns true on 204 No Content', () async {
      when(
        () => apiClient.delete(ApiEndpoints.deleteWalletUrl('w1')),
      ).thenAnswer((_) async => buildResponse(statusCode: 204));

      final result = await service.deleteMoneySource('w1');

      expect(result, true);
    });

    test('returns false on non-success status', () async {
      when(
        () => apiClient.delete(ApiEndpoints.deleteWalletUrl('w1')),
      ).thenAnswer((_) async => buildResponse(statusCode: 404));

      final result = await service.deleteMoneySource('w1');

      expect(result, false);
    });

    test('throws exception when id is empty', () async {
      expect(
        () => service.deleteMoneySource(''),
        throwsException,
      );
    });

    test('throws exception when id is whitespace', () async {
      expect(
        () => service.deleteMoneySource('   '),
        throwsException,
      );
    });

    test('throws on DioException', () async {
      when(
        () => apiClient.delete(ApiEndpoints.deleteWalletUrl('w1')),
      ).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(
        () => service.deleteMoneySource('w1'),
        throwsException,
      );
    });
  });

  group('MoneySourceService - Error Handling', () {
    test('handles cancel exception', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.wallets,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(DioException(
        type: DioExceptionType.cancel,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(
        () => service.getAllMoneySources(),
        throwsException,
      );
    });

    test('handles bad response exception', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.wallets,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
          data: {'message': 'Server error'},
        ),
      ));

      expect(
        () => service.getAllMoneySources(),
        throwsException,
      );
    });

    test('handles unknown exception', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.wallets,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(DioException(
        type: DioExceptionType.unknown,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(
        () => service.getAllMoneySources(),
        throwsException,
      );
    });
  });
}
