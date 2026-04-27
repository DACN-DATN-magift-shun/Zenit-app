import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/statistics/services/statistics_service.dart';

import '../../../mocks/features/statistics/services/statistics_service_mock_data.dart';
import '../../../mocks/network/api_client_mocks.dart';

void main() {
  late MockApiClient apiClient;
  late StatisticsService service;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    apiClient = MockApiClient();
    service = StatisticsService(apiClient: apiClient);
  });

  test('getStatistics parses response model', () async {
    when(
      () => apiClient.get(ApiEndpoints.statistics, queryParameters: any(named: 'queryParameters')),
    ).thenAnswer((_) async => buildResponse(statusCode: 200, data: statisticsResponseData));

    final result = await service.getStatistics(
      from: DateTime.parse('2026-01-01T00:00:00Z'),
      to: DateTime.parse('2026-01-31T00:00:00Z'),
    );

    expect(result.items.length, 1);
    expect(result.incomeExpenseStatistics.totalIncome, 100);
  });

  test('exportReport throws unimplemented error', () {
    expect(() => service.exportReport(), throwsA(isA<UnimplementedError>()));
  });
}
