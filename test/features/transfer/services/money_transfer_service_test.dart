import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/transfer/services/money_transfer_service.dart';

import '../../../mocks/features/transfer/services/money_transfer_service_mock_data.dart';
import '../../../mocks/features/transfer/money_transfer_model_mock_data.dart';
import '../../../mocks/network/api_client_mocks.dart';

void main() {
  late MockApiClient apiClient;
  late MoneyTransferService service;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    apiClient = MockApiClient();
    service = MoneyTransferService(apiClient: apiClient);
  });

  test('getMoneyTransfers sends filters and parses list response', () async {
    when(
      () => apiClient.get(
        ApiEndpoints.moneyTransfers,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => buildResponse(statusCode: 200, data: moneyTransferListResponseData));

    final fromDate = DateTime.utc(2026, 4, 26, 1);
    final toDate = DateTime.utc(2026, 4, 27, 2);

    final result = await service.getMoneyTransfers(
      fromDate: fromDate,
      toDate: toDate,
      search: '  move  ',
      beforeId: '  t9 ',
      pageSize: 25,
      useCountTotal: false,
    );

    final captured = verify(
      () => apiClient.get(
        ApiEndpoints.moneyTransfers,
        queryParameters: captureAny(named: 'queryParameters'),
      ),
    ).captured.single as Map<String, dynamic>;

    expect(result.items.length, 1);
    expect(result.items.first.id, 't1');
    expect(captured['PageSize'], 25);
    expect(captured['UseCountTotal'], isFalse);
    expect(captured['FromDate'], fromDate.toUtc().toIso8601String());
    expect(captured['ToDate'], toDate.toUtc().toIso8601String());
    expect(captured['Search'], 'move');
    expect(captured['BeforeId'], 't9');
  });

  test('getMoneyTransfers omits optional filters and accepts string payload', () async {
    when(
      () => apiClient.get(
        ApiEndpoints.moneyTransfers,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => buildResponse(
        statusCode: 200,
        data: jsonEncode(moneyTransferListResponseData),
      ),
    );

    final result = await service.getMoneyTransfers(pageSize: 10);

    final captured = verify(
      () => apiClient.get(
        ApiEndpoints.moneyTransfers,
        queryParameters: captureAny(named: 'queryParameters'),
      ),
    ).captured.single as Map<String, dynamic>;

    expect(result.items.length, 1);
    expect(captured.keys, containsAll(<String>['PageSize', 'UseCountTotal']));
    expect(captured, hasLength(2));
    expect(captured['PageSize'], 10);
    expect(captured['UseCountTotal'], isTrue);
  });

  test('getMoneyTransferById parses item response', () async {
    when(
      () => apiClient.get(ApiEndpoints.moneyTransferById('t1')),
    ).thenAnswer(
      (_) async => buildResponse(
        statusCode: 200,
        data: moneyTransferFromJsonMockData['result'],
      ),
    );

    final result = await service.getMoneyTransferById('t1');

    expect(result.id, 'mt1');
    expect(result.amount, 100000);
    expect(result.fromWallet?.name, 'Cash');
  });

  test('getMoneyTransferById maps bad response errors', () async {
    when(() => apiClient.get(ApiEndpoints.moneyTransferById('t1'))).thenThrow(
      buildDioException(
        type: DioExceptionType.badResponse,
        statusCode: 404,
        data: {'message': 'Transfer not found'},
      ),
    );

    await expectLater(
      service.getMoneyTransferById('t1'),
      throwsA(
        predicate(
          (error) => error.toString().contains('Server error (404): Transfer not found'),
        ),
      ),
    );
  });

  test('createMoneyTransfer returns fallback model when response body is empty', () async {
    when(
      () => apiClient.post(
        ApiEndpoints.createMoneyTransfer,
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => buildResponse(statusCode: 201, data: {}));

    final transferDate = DateTime.utc(2026, 4, 26);
    final result = await service.createMoneyTransfer(
      fromWalletId: 'w1',
      toWalletId: 'w2',
      amount: 50000,
      transferDate: transferDate,
      note: 'move funds',
    );

    final captured = verify(
      () => apiClient.post(
        ApiEndpoints.createMoneyTransfer,
        data: captureAny(named: 'data'),
      ),
    ).captured.single as Map<String, dynamic>;

    expect(captured['fromWalletId'], 'w1');
    expect(captured['toWalletId'], 'w2');
    expect(captured['amount'], 50000);
    expect(captured['transferDate'], transferDate.toUtc().toIso8601String());
    expect(captured['note'], 'move funds');
    expect(result.id, '');
    expect(result.fromWalletId, 'w1');
    expect(result.amount, 50000);
  });

  test('createMoneyTransfer parses response body when it is present', () async {
    when(
      () => apiClient.post(
        ApiEndpoints.createMoneyTransfer,
        data: any(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => buildResponse(
        statusCode: 201,
        data: {
          'id': 't99',
          'fromWalletId': 'w1',
          'toWalletId': 'w2',
          'amount': 70000,
          'transferDate': '2026-04-26T00:00:00Z',
          'note': 'parsed',
        },
      ),
    );

    final result = await service.createMoneyTransfer(
      fromWalletId: 'w1',
      toWalletId: 'w2',
      amount: 70000,
      transferDate: DateTime.utc(2026, 4, 26),
      note: 'parsed',
    );

    expect(result.id, 't99');
    expect(result.note, 'parsed');
  });

  test('createMoneyTransfer maps connection timeout errors', () async {
    when(
      () => apiClient.post(
        ApiEndpoints.createMoneyTransfer,
        data: any(named: 'data'),
      ),
    ).thenThrow(buildDioException(type: DioExceptionType.connectionTimeout));

    await expectLater(
      service.createMoneyTransfer(
        fromWalletId: 'w1',
        toWalletId: 'w2',
        amount: 1,
        transferDate: DateTime.utc(2026, 4, 26),
      ),
      throwsA(
        predicate(
          (error) => error.toString().contains('Connection timeout. Please check your internet connection.'),
        ),
      ),
    );
  });

  test('updateMoneyTransfer returns fallback model when response body is empty', () async {
    when(
      () => apiClient.patch(
        ApiEndpoints.updateMoneyTransferUrl('t1'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => buildResponse(statusCode: 200, data: {}));

    final transferDate = DateTime.utc(2026, 4, 27);
    final result = await service.updateMoneyTransfer(
      id: 't1',
      fromWalletId: 'w1',
      toWalletId: 'w2',
      amount: 60000,
      transferDate: transferDate,
      note: 'updated note',
    );

    final captured = verify(
      () => apiClient.patch(
        ApiEndpoints.updateMoneyTransferUrl('t1'),
        data: captureAny(named: 'data'),
      ),
    ).captured.single as Map<String, dynamic>;

    expect(captured['id'], 't1');
    expect(captured['amount'], 60000);
    expect(captured['transferDate'], transferDate.toUtc().toIso8601String());
    expect(result.id, 't1');
    expect(result.note, 'updated note');
  });

  test('updateMoneyTransfer parses response body when it is present', () async {
    when(
      () => apiClient.patch(
        ApiEndpoints.updateMoneyTransferUrl('t1'),
        data: any(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => buildResponse(
        statusCode: 200,
        data: jsonEncode({
          'id': 't1',
          'fromWalletId': 'w3',
          'toWalletId': 'w4',
          'amount': 61000,
          'transferDate': '2026-04-27T00:00:00Z',
          'note': 'json',
        }),
      ),
    );

    final result = await service.updateMoneyTransfer(
      id: 't1',
      fromWalletId: 'w3',
      toWalletId: 'w4',
      amount: 61000,
      transferDate: DateTime.utc(2026, 4, 27),
      note: 'json',
    );

    expect(result.id, 't1');
    expect(result.amount, 61000);
    expect(result.note, 'json');
  });

  test('updateMoneyTransfer maps receive timeout errors', () async {
    when(
      () => apiClient.patch(
        ApiEndpoints.updateMoneyTransferUrl('t1'),
        data: any(named: 'data'),
      ),
    ).thenThrow(buildDioException(type: DioExceptionType.receiveTimeout));

    await expectLater(
      service.updateMoneyTransfer(
        id: 't1',
        fromWalletId: 'w1',
        toWalletId: 'w2',
        amount: 1,
        transferDate: DateTime.utc(2026, 4, 26),
        note: '',
      ),
      throwsA(
        predicate(
          (error) => error.toString().contains('Server is taking too long to respond.'),
        ),
      ),
    );
  });

  test('deleteMoneyTransfer returns true on success', () async {
    when(
      () => apiClient.delete(ApiEndpoints.deleteMoneyTransferUrl('t1')),
    ).thenAnswer((_) async => buildResponse(statusCode: 204));

    final result = await service.deleteMoneyTransfer('t1');

    expect(result, isTrue);
  });

  test('deleteMoneyTransfer returns false on non-success status', () async {
    when(
      () => apiClient.delete(ApiEndpoints.deleteMoneyTransferUrl('t1')),
    ).thenAnswer((_) async => buildResponse(statusCode: 500));

    final result = await service.deleteMoneyTransfer('t1');

    expect(result, isFalse);
  });

  test('deleteMoneyTransfer maps cancelled requests', () async {
    when(
      () => apiClient.delete(ApiEndpoints.deleteMoneyTransferUrl('t1')),
    ).thenThrow(buildDioException(type: DioExceptionType.cancel));

    await expectLater(
      service.deleteMoneyTransfer('t1'),
      throwsA(
        predicate((error) => error.toString().contains('Request was cancelled.')),
      ),
    );
  });

  test('deleteMoneyTransfer throws on empty id', () async {
    expect(() => service.deleteMoneyTransfer(''), throwsException);
  });

  test('getMoneyTransfers maps unknown dio errors', () async {
    when(
      () => apiClient.get(
        ApiEndpoints.moneyTransfers,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenThrow(
      buildDioException(type: DioExceptionType.unknown, message: 'offline'),
    );

    await expectLater(
      service.getMoneyTransfers(pageSize: 1),
      throwsA(
        predicate((error) => error.toString().contains('Network error: offline')),
      ),
    );
  });

  test('getMoneyTransfers maps string bad response errors', () async {
    when(
      () => apiClient.get(
        ApiEndpoints.moneyTransfers,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenThrow(
      buildDioException(
        type: DioExceptionType.badResponse,
        statusCode: 502,
        data: 'bad gateway',
      ),
    );

    await expectLater(
      service.getMoneyTransfers(pageSize: 1),
      throwsA(
        predicate((error) => error.toString().contains('Server error (502): bad gateway')),
      ),
    );
  });
}
