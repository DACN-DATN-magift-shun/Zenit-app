import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/loans/services/loans_service.dart';

import '../../../mocks/features/loans/services/loans_service_mock_data.dart';
import '../../../mocks/network/api_client_mocks.dart';

void main() {
  late MockApiClient apiClient;
  late LoansService service;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    apiClient = MockApiClient();
    service = LoansService(apiClient: apiClient);
  });

  test('getLoans parses list response', () async {
    when(
      () => apiClient.get(ApiEndpoints.loans, queryParameters: any(named: 'queryParameters')),
    ).thenAnswer((_) async => buildResponse(statusCode: 200, data: loansListResponseData));

    final result = await service.getLoans(pageSize: 100);

    expect(result.length, 1);
    expect(result.first.id, 'l1');
  });

  test('deleteLoan throws when id is empty', () async {
    expect(() => service.deleteLoan('  '), throwsException);
  });

  test('deleteLoan returns true for 204', () async {
    when(() => apiClient.delete(ApiEndpoints.deleteLoanUrl('l1')))
        .thenAnswer((_) async => buildResponse(statusCode: 204));

    final result = await service.deleteLoan('l1');

    expect(result, true);
  });
}
