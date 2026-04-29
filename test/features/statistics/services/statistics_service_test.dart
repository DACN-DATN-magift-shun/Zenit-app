import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/statistics/services/statistics_service.dart';

import '../../../mocks/features/statistics/services/statistics_service_mock_data.dart';
import '../../../mocks/network/api_client_mocks.dart';

void main() {
  late MockApiClient apiClient;
  late StatisticsService service;
  late UrlLauncherPlatform originalLauncherPlatform;
  late _FakeUrlLauncherPlatform launcherPlatform;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(Options());
  });

  setUp(() {
    apiClient = MockApiClient();
    service = StatisticsService(apiClient: apiClient);
    originalLauncherPlatform = UrlLauncherPlatform.instance;
    launcherPlatform = _FakeUrlLauncherPlatform();
    UrlLauncherPlatform.instance = launcherPlatform;
  });

  tearDown(() {
    UrlLauncherPlatform.instance = originalLauncherPlatform;
  });

  test('getStatistics parses a string payload with default dates', () async {
    when(
      () => apiClient.get(
        ApiEndpoints.statistics,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => buildResponse(
        statusCode: 200,
        data:
            '{"groupStatistics":[{"totalAmount":100,"percentage":50,"percentageChange":1,"groupType":0,"categoryStatistics":[]}],"incomeExpenseStatistics":{"totalIncome":100,"totalExpense":50,"incomePercentageChange":1,"expensePercentageChange":-1}}',
      ),
    );

    final result = await service.getStatistics();

    expect(result.items.length, 1);
    expect(result.incomeExpenseStatistics.totalIncome, 100);
  });

  test(
    'getStatistics sends end-of-day query parameters when to is provided',
    () async {
      when(
        () => apiClient.get(
          ApiEndpoints.statistics,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async =>
            buildResponse(statusCode: 200, data: statisticsResponseData),
      );

      await service.getStatistics(
        from: DateTime(2026, 1, 1),
        to: DateTime(2026, 1, 31),
      );

      final captured =
          verify(
                () => apiClient.get(
                  ApiEndpoints.statistics,
                  queryParameters: captureAny(named: 'queryParameters'),
                ),
              ).captured.single
              as Map<String, dynamic>;

      expect(captured['From'], DateTime(2026, 1, 1).toUtc().toIso8601String());
      expect(
        captured['To'],
        DateTime(2026, 1, 31, 23, 59, 59, 999).toUtc().toIso8601String(),
      );
    },
  );

  test('getStatistics maps dio errors with and without a response', () async {
    when(
      () => apiClient.get(
        ApiEndpoints.statistics,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenThrow(
      buildDioException(
        type: DioExceptionType.badResponse,
        statusCode: 500,
        data: {'message': 'service unavailable'},
      ),
    );

    expect(() => service.getStatistics(), throwsA(isA<Exception>()));

    when(
      () => apiClient.get(
        ApiEndpoints.statistics,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenThrow(buildDioException(type: DioExceptionType.connectionTimeout));

    expect(() => service.getStatistics(), throwsA(isA<Exception>()));
  });

  test('exportReport throws when report URL is missing', () {
    when(
      () => apiClient.post(
        ApiEndpoints.statisticsReports,
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => buildResponse(statusCode: 200, data: <String, dynamic>{}),
    );

    expect(() => service.exportReport(), throwsA(isA<Exception>()));
  });

  test('exportReport launches the returned report URL', () async {
    when(
      () => apiClient.post(
        ApiEndpoints.statisticsReports,
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => buildResponse(
        statusCode: 200,
        data: {'reportUrl': 'https://example.com/report.pdf'},
      ),
    );

    await service.exportReport(
      from: DateTime.parse('2026-01-01T00:00:00Z'),
      to: DateTime.parse('2026-01-31T00:00:00Z'),
    );

    expect(launcherPlatform.lastLaunchedUrl, 'https://example.com/report.pdf');
    expect(launcherPlatform.lastLaunchMode, LaunchMode.externalApplication);
  });

  test(
    'exportReport rejects invalid URLs, failed launches, and non-success statuses',
    () async {
      when(
        () => apiClient.post(
          ApiEndpoints.statisticsReports,
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => buildResponse(
          statusCode: 200,
          data: {'reportUrl': 'http://[invalid-url]'},
        ),
      );

      expect(() => service.exportReport(), throwsA(isA<Exception>()));

      when(
        () => apiClient.post(
          ApiEndpoints.statisticsReports,
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => buildResponse(
          statusCode: 200,
          data: {'reportUrl': 'https://example.com/report.pdf'},
        ),
      );

      launcherPlatform.shouldLaunch = false;
      expect(() => service.exportReport(), throwsA(isA<Exception>()));

      when(
        () => apiClient.post(
          ApiEndpoints.statisticsReports,
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => buildResponse(
          statusCode: 500,
          data: {'reportUrl': 'https://example.com/report.pdf'},
        ),
      );

      expect(() => service.exportReport(), throwsA(isA<Exception>()));
    },
  );
}

class _FakeUrlLauncherPlatform extends UrlLauncherPlatform {
  String? lastLaunchedUrl;
  LaunchMode? lastLaunchMode;
  bool shouldLaunch = true;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async {
    lastLaunchedUrl = url;
    lastLaunchMode = LaunchMode.externalApplication;
    return shouldLaunch;
  }

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';
}
