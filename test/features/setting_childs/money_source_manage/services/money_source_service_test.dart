import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

  test('getAllMoneySources parses wallets list', () async {
    when(
      () => apiClient.get(ApiEndpoints.wallets, queryParameters: const {'PageSize': 100}),
    ).thenAnswer((_) async => buildResponse(statusCode: 200, data: walletsListResponseData));

    final result = await service.getAllMoneySources();

    expect(result.length, 1);
    expect(result.first.id, 'w1');
  });

  test('deleteMoneySource throws when id is empty', () async {
    expect(() => service.deleteMoneySource(' '), throwsException);
  });
}
