import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/transaction/models/transaction_model.dart';
import 'package:zenit/features/transaction/services/transaction_service.dart';

import '../../../mocks/features/transaction/services/transaction_service_mock_data.dart';
import '../../../mocks/network/api_client_mocks.dart';

void main() {
  late MockApiClient apiClient;
  late TransactionService service;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    apiClient = MockApiClient();
    service = TransactionService(apiClient: apiClient);
  });

  test('getAllTransactions parses list response', () async {
    when(
      () => apiClient.get(ApiEndpoints.transactions, queryParameters: any(named: 'queryParameters')),
    ).thenAnswer((_) async => buildResponse(statusCode: 200, data: transactionListResponseData));

    final result = await service.getAllTransactions(pageSize: 20);

    expect(result.items.length, 1);
    expect(result.items.first.id, 'tx1');
  });

  test('updateTransactions sends transaction list payload', () async {
    final items = (transactionListResponseData['items'] as List<dynamic>);
    final transaction = TransactionModel.fromJson(items.first as Map<String, dynamic>);

    when(() => apiClient.patch(ApiEndpoints.transactions, data: any(named: 'data')))
        .thenAnswer((_) async => buildResponse(statusCode: 200));

    final result = await service.updateTransactions([transaction]);

    expect(result, true);
    verify(() => apiClient.patch(ApiEndpoints.transactions, data: any(named: 'data'))).called(1);
  });
}
