import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/transfer/services/money_transfer_service.dart';

import '../../../mocks/features/transfer/services/money_transfer_service_mock_data.dart';
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

  test('getMoneyTransfers parses list response', () async {
    when(
      () => apiClient.get(ApiEndpoints.moneyTransfers, queryParameters: any(named: 'queryParameters')),
    ).thenAnswer((_) async => buildResponse(statusCode: 200, data: moneyTransferListResponseData));

    final result = await service.getMoneyTransfers(pageSize: 100);

    expect(result.items.length, 1);
    expect(result.items.first.id, 't1');
  });

  test('deleteMoneyTransfer throws on empty id', () async {
    expect(() => service.deleteMoneyTransfer(''), throwsException);
  });
}
