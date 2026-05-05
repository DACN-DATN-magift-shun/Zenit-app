import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/core/services/auth_service.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/data/local/storage_service.dart';

import '../../mocks/network/fake_http_client_adapter.dart';
import '../../mocks/platform/secure_storage_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SecureStorageTestController storage;
  late dynamic originalAdapter;
  late AuthService service;

  setUp(() {
    storage = SecureStorageTestController();
    storage.install();

    originalAdapter = ApiClient().dio.httpClientAdapter;
    service = AuthService();
  });

  tearDown(() {
    ApiClient().dio.httpClientAdapter = originalAdapter;
    storage.uninstall();
  });

  String buildJwt({required int exp}) {
    final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'none'})));
    final payload = base64Url.encode(utf8.encode(jsonEncode({'exp': exp})));
    return '$header.$payload.signature';
  }

  test('isAuthenticated clears expired tokens', () async {
    final expiredToken = buildJwt(
      exp: DateTime.now().millisecondsSinceEpoch ~/ 1000 - 60,
    );
    await service.saveLoginData(accessToken: expiredToken, refreshToken: 'refresh');

    final result = await service.isAuthenticated();

    expect(result, isFalse);
    expect(storage.snapshot()[StorageService.accessTokenKey], isNull);
    expect(storage.snapshot()[StorageService.refreshTokenKey], isNull);
  });

  test('getUserDisplayName reads username from account response', () async {
    final validToken = buildJwt(
      exp: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
    );
    await service.saveLoginData(accessToken: validToken, refreshToken: 'refresh');

    ApiClient().dio.httpClientAdapter = FakeHttpClientAdapter((options) {
      if (options.path == ApiEndpoints.accounts) {
        return jsonResponse({
          'data': {'username': 'alice'},
        });
      }

      return jsonResponse({}, statusCode: 404);
    });

    final displayName = await service.getUserDisplayName();

    expect(displayName, 'alice');
  });

  test('getUserDisplayName handles list-wrapped data', () async {
    final validToken = buildJwt(
      exp: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
    );
    await service.saveLoginData(accessToken: validToken, refreshToken: 'refresh');

    ApiClient().dio.httpClientAdapter = FakeHttpClientAdapter((options) {
      if (options.path == ApiEndpoints.accounts) {
        return jsonResponse({
          'data': [
            {'username': 'carol'},
          ],
        });
      }

      return jsonResponse({}, statusCode: 404);
    });

    final displayName = await service.getUserDisplayName();

    expect(displayName, 'carol');
  });

  test('getUserDisplayName handles stringified data', () async {
    final validToken = buildJwt(
      exp: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
    );
    await service.saveLoginData(accessToken: validToken, refreshToken: 'refresh');

    ApiClient().dio.httpClientAdapter = FakeHttpClientAdapter((options) {
      if (options.path == ApiEndpoints.accounts) {
        return jsonResponse({
          'data': jsonEncode({'username': 'dave'}),
        });
      }

      return jsonResponse({}, statusCode: 404);
    });

    final displayName = await service.getUserDisplayName();

    expect(displayName, 'dave');
  });

  test('isAuthenticated returns true for valid token', () async {
    final validToken = buildJwt(
      exp: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
    );
    await service.saveLoginData(accessToken: validToken, refreshToken: 'refresh');

    final result = await service.isAuthenticated();

    expect(result, isTrue);
  });

  test('getUserInfo clears storage on 401', () async {
    final validToken = buildJwt(
      exp: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
    );
    await service.saveLoginData(accessToken: validToken, refreshToken: 'refresh');

    ApiClient().dio.httpClientAdapter = FakeHttpClientAdapter((options) {
      // Simulate DioException by throwing one from the adapter
      throw DioException(
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: 401, data: ''),
      );
    });

    final result = await service.getUserInfo();

    expect(result, isNull);
    expect(storage.snapshot()[StorageService.accessTokenKey], isNull);
    expect(storage.snapshot()[StorageService.refreshTokenKey], isNull);
  });

  test('logout clears stored session data', () async {
    await service.saveLoginData(accessToken: 'a', refreshToken: 'b');
    await service.saveSignupData(userId: 'user-1');

    await service.logout();

    expect(storage.snapshot()[StorageService.accessTokenKey], isNull);
    expect(storage.snapshot()[StorageService.refreshTokenKey], isNull);
    expect(storage.snapshot()[StorageService.userIdKey], isNull);
  });
}