import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/auth/services/account_service.dart';

import '../../../mocks/features/auth/services/account_service_mock_data.dart';
import '../../../mocks/network/api_client_mocks.dart';

void main() {
  late MockApiClient apiClient;
  late AccountService service;

  setUp(() {
    apiClient = MockApiClient();
    service = AccountService(apiClient: apiClient);
  });

  test('register posts expected payload', () async {
    when(() => apiClient.post(ApiEndpoints.register, data: registerPayload))
        .thenAnswer((_) async => buildResponse(statusCode: 200, data: {'ok': true}));

    await service.register(
      username: 'john',
      email: 'john@example.com',
      phone: '0123456789',
      address: 'HN',
      password: 'Passw0rd!',
    );

    verify(() => apiClient.post(ApiEndpoints.register, data: registerPayload)).called(1);
  });

  test('updateMyAccount omits empty photoId', () async {
    when(() => apiClient.patch(ApiEndpoints.accounts, data: {
      'phone': '0123',
      'address': 'HN',
    })).thenAnswer((_) async => buildResponse(statusCode: 200));

    await service.updateMyAccount(phone: '0123', address: 'HN');

    verify(() => apiClient.patch(ApiEndpoints.accounts, data: {
      'phone': '0123',
      'address': 'HN',
    })).called(1);
  });

  test('login posts expected payload', () async {
    when(() => apiClient.post(ApiEndpoints.login, data: loginPayload))
        .thenAnswer((_) async => buildResponse(statusCode: 200, data: {'token': 'x'}));

    await service.login(email: 'john@example.com', password: 'Passw0rd!');

    verify(() => apiClient.post(ApiEndpoints.login, data: loginPayload)).called(1);
  });
}
