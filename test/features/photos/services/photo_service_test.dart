import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/photos/services/photo_service.dart';

import '../../../mocks/features/photos/services/photo_service_mock_data.dart';
import '../../../mocks/network/api_client_mocks.dart';

void main() {
  late MockApiClient apiClient;
  late MockStorageService storageService;
  late PhotoService service;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(Options());
  });

  setUp(() {
    apiClient = MockApiClient();
    storageService = MockStorageService();
    service = PhotoService(apiClient: apiClient, storageService: storageService);
  });

  test('getPhotos includes bearer token in options headers', () async {
    when(() => storageService.getAccessToken()).thenAnswer((_) async => 'token-123');
    when(
      () => apiClient.get(
        ApiEndpoints.photos,
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => buildResponse(statusCode: 200, data: photoListData));

    final result = await service.getPhotos(pageSize: 20);

    expect(result.items.length, 1);
    final captured = verify(
      () => apiClient.get(
        ApiEndpoints.photos,
        queryParameters: any(named: 'queryParameters'),
        options: captureAny(named: 'options'),
      ),
    ).captured.single as Options;
    expect(captured.headers?['Authorization'], 'Bearer token-123');
  });
}
