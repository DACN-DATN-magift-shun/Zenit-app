import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/local/storage_service.dart';
import 'package:zenit/data/network/api_client.dart';

import '../../mocks/network/fake_http_client_adapter.dart';
import '../../mocks/platform/secure_storage_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SecureStorageTestController storage;
  late dynamic originalAdapter;
  late ApiClient client;

  setUp(() {
    storage = SecureStorageTestController(initialValues: {
      StorageService.accessTokenKey: 'token-123',
      StorageService.refreshTokenKey: 'refresh-123',
    });
    storage.install();

    originalAdapter = ApiClient().dio.httpClientAdapter;
    client = ApiClient();
  });

  tearDown(() {
    ApiClient().dio.httpClientAdapter = originalAdapter;
    storage.uninstall();
  });

  test('adds bearer token to outgoing requests', () async {
    RequestOptionsCapture? capture;
    ApiClient().dio.httpClientAdapter = FakeHttpClientAdapter((options) {
      capture = RequestOptionsCapture(options);
      return jsonResponse({'ok': true});
    });

    await client.get('${ApiEndpoints.baseUrl}ping');

    expect(capture?.headers?['Authorization'], 'Bearer token-123');
  });

  test('clears storage for unauthorized non-auth responses', () async {
    ApiClient().dio.httpClientAdapter = FakeHttpClientAdapter((options) {
      return jsonResponse(
        {'message': 'Unauthorized'},
        statusCode: 401,
      );
    });

    await expectLater(
      client.get(ApiEndpoints.transactions),
      throwsA(isA<DioException>()),
    );

    expect(storage.snapshot()[StorageService.accessTokenKey], isNull);
    expect(storage.snapshot()[StorageService.refreshTokenKey], isNull);
  });

  test('keeps storage for unauthorized auth responses', () async {
    ApiClient().dio.httpClientAdapter = FakeHttpClientAdapter((options) {
      return jsonResponse(
        {'message': 'Unauthorized'},
        statusCode: 401,
      );
    });

    await expectLater(
      client.get(ApiEndpoints.login),
      throwsA(isA<DioException>()),
    );

    expect(storage.snapshot()[StorageService.accessTokenKey], 'token-123');
    expect(storage.snapshot()[StorageService.refreshTokenKey], 'refresh-123');
  });
}

class RequestOptionsCapture {
  RequestOptionsCapture(this.requestOptions);

  final RequestOptions requestOptions;

  Map<String, dynamic>? get headers => requestOptions.headers;
}