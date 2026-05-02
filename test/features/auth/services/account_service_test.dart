import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/auth/services/account_service.dart';

import '../../../mocks/network/api_client_mocks.dart';

void main() {
  late MockApiClient apiClient;
  late AccountService service;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    apiClient = MockApiClient();
    service = AccountService(apiClient: apiClient);
  });

  group('AccountService', () {
    test('register posts payload and returns response', () async {
      when(() => apiClient.post(ApiEndpoints.register, data: any(named: 'data')))
          .thenAnswer((_) async =>
              buildResponse(statusCode: 201, data: {'id': 'u1'}));

      final resp = await service.register(
        username: 'u',
        email: 'e@x.com',
        phone: '0123',
        address: 'addr',
        password: 'p',
      );

      expect(resp.statusCode, 201);
      verify(() => apiClient.post(ApiEndpoints.register, data: {
            'username': 'u',
            'email': 'e@x.com',
            'phone': '0123',
            'address': 'addr',
            'password': 'p',
          })).called(1);
    });

    test('login posts credentials', () async {
      when(() => apiClient.post(ApiEndpoints.login, data: any(named: 'data')))
          .thenAnswer((_) async => buildResponse(statusCode: 200, data: {
                'accessToken': 'tok',
              }));

      final resp = await service.login(email: 'e@x.com', password: 'pw');

      expect(resp.statusCode, 200);
      verify(() => apiClient.post(ApiEndpoints.login,
          data: {'email': 'e@x.com', 'password': 'pw'})).called(1);
    });

    test('getAccount calls get and returns data', () async {
      when(() => apiClient.get(ApiEndpoints.accounts))
          .thenAnswer((_) async => buildResponse(statusCode: 200, data: {
                'username': 'u1',
              }));

      final resp = await service.getAccount();

      expect(resp.statusCode, 200);
      expect(resp.data['username'], 'u1');
      verify(() => apiClient.get(ApiEndpoints.accounts)).called(1);
    });

    test('updateAccount calls put with id and data', () async {
      when(() => apiClient.put(ApiEndpoints.accounts, data: any(named: 'data')))
          .thenAnswer((_) async => buildResponse(statusCode: 200, data: {}));

      final resp = await service.updateAccount('id1', {'a': 1});

      expect(resp.statusCode, 200);
      verify(() => apiClient.put(ApiEndpoints.accounts, data: {'a': 1})).called(1);
    });

    test('updateMyAccount includes photoId when provided', () async {
      when(() => apiClient.patch(ApiEndpoints.accounts, data: any(named: 'data')))
          .thenAnswer((_) async => buildResponse(statusCode: 200, data: {}));

      await service.updateMyAccount(phone: '012', address: 'a', photoId: 'p1');

      verify(() => apiClient.patch(ApiEndpoints.accounts, data: {
            'phone': '012',
            'address': 'a',
            'photoId': 'p1',
          })).called(1);
    });

    test('updateMyAccount omits photoId when null or empty', () async {
      when(() => apiClient.patch(ApiEndpoints.accounts, data: any(named: 'data')))
          .thenAnswer((_) async => buildResponse(statusCode: 200, data: {}));

      await service.updateMyAccount(phone: '012', address: 'a', photoId: '');

      verify(() => apiClient.patch(ApiEndpoints.accounts,
          data: {'phone': '012', 'address': 'a'})).called(1);
    });

    test('deleteAccount calls delete', () async {
      when(() => apiClient.delete(ApiEndpoints.accounts))
          .thenAnswer((_) async => buildResponse(statusCode: 204, data: {}));

      final resp = await service.deleteAccount('id');

      expect(resp.statusCode, 204);
      verify(() => apiClient.delete(ApiEndpoints.accounts)).called(1);
    });

    test('sendOtp posts email', () async {
      when(() => apiClient.post(ApiEndpoints.sendOtp, data: any(named: 'data')))
          .thenAnswer((_) async => buildResponse(statusCode: 200, data: {}));

      await service.sendOtp(email: 'e@x.com');

      verify(() => apiClient.post(ApiEndpoints.sendOtp, data: {'email': 'e@x.com'})).called(1);
    });

    test('verifyOtp posts email and otp', () async {
      when(() => apiClient.post(ApiEndpoints.verifyOtp, data: any(named: 'data')))
          .thenAnswer((_) async => buildResponse(statusCode: 200, data: {}));

      await service.verifyOtp(email: 'e@x.com', otp: '1234');

      verify(() => apiClient.post(ApiEndpoints.verifyOtp, data: {
            'email': 'e@x.com',
            'otp': '1234',
          })).called(1);
    });

    test('resetPassword posts resetToken and newPassword', () async {
      when(() => apiClient.post(ApiEndpoints.resetPassword, data: any(named: 'data')))
          .thenAnswer((_) async => buildResponse(statusCode: 200, data: {}));

      await service.resetPassword(resetToken: 't', newPassword: 'np');

      verify(() => apiClient.post(ApiEndpoints.resetPassword, data: {
            'resetToken': 't',
            'newPassword': 'np',
          })).called(1);
    });

    test('login propagates DioException', () async {
      when(() => apiClient.post(ApiEndpoints.login, data: any(named: 'data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.receiveTimeout,
      ));

      expect(() => service.login(email: 'e', password: 'p'), throwsException);
    });
  });
}

