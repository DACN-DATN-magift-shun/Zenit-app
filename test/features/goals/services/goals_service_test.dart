import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/goals/models/goal_model.dart';
import 'package:zenit/features/goals/services/goals_service.dart';

import '../../../mocks/features/goals/services/goals_service_mock_data.dart';
import '../../../mocks/network/api_client_mocks.dart';

void main() {
  late MockApiClient apiClient;
  late GoalsService service;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    apiClient = MockApiClient();
    service = GoalsService(apiClient: apiClient);
  });

  test('getGoals trims query parameters and reads top-level list', () async {
    when(
      () => apiClient.get(
        ApiEndpoints.goals,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => buildResponse(statusCode: 200, data: goalsListResponseData['items']),
    );

    final result = await service.getGoals(
      search: '  goal  ',
      beforeId: '  g0  ',
      pageSize: 25,
      useCountTotal: true,
    );

    final captured = verify(
      () => apiClient.get(
        ApiEndpoints.goals,
        queryParameters: captureAny(named: 'queryParameters'),
      ),
    ).captured.single as Map<String, dynamic>;

    expect(captured['PageSize'], 25);
    expect(captured['Search'], 'goal');
    expect(captured['BeforeId'], 'g0');
    expect(captured['UseCountTotal'], true);
    expect(result.length, 1);
    expect(result.first.id, 'g1');
  });

  test('getGoals supports alternate list shapes', () async {
    final cases = <({String name, dynamic data, int length, String? id})>[
      (
        name: 'items list',
        data: {'items': goalsListResponseData['items']},
        length: 1,
        id: 'g1',
      ),
      (
        name: 'goals list',
        data: {'goals': goalsListResponseData['items']},
        length: 1,
        id: 'g1',
      ),
      (
        name: 'nested data items',
        data: {
          'data': {'items': goalsListResponseData['items']},
        },
        length: 1,
        id: 'g1',
      ),
      (
        name: 'single object fallback',
        data: goalsListResponseData['items']!.first,
        length: 1,
        id: 'g1',
      ),
      (
        name: 'empty payload',
        data: <String, dynamic>{},
        length: 0,
        id: null,
      ),
    ];

    for (final testCase in cases) {
      when(
        () => apiClient.get(
          ApiEndpoints.goals,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => buildResponse(statusCode: 200, data: testCase.data),
      );

      final result = await service.getGoals(pageSize: 100);

      expect(result.length, testCase.length, reason: testCase.name);
      if (testCase.id != null) {
        expect(result.single.id, testCase.id, reason: testCase.name);
      }
    }
  });

  test('getGoalById parses a direct object payload', () async {
    when(() => apiClient.get(ApiEndpoints.goalById('g1'))).thenAnswer(
      (_) async => buildResponse(statusCode: 200, data: goalsListResponseData['items']!.first),
    );

    final result = await service.getGoalById('g1');

    expect(result.id, 'g1');
    expect(result.name, 'Goal 1');
  });

  test('createGoal returns fallback model when response body is empty', () async {
    when(
      () => apiClient.post(ApiEndpoints.createGoal, data: any(named: 'data')),
    ).thenAnswer((_) async => buildResponse(statusCode: 201, data: null));

    final result = await service.createGoal(
      name: 'Goal',
      targetAmount: 100,
      currentAmount: 10,
      backgroundColor: '#D2E4FF',
      icon: 'flag',
      dueDate: DateTime.parse('2026-12-01T00:00:00Z'),
      note: '',
      status: GoalStatus.ongoing,
    );

    expect(result.name, 'Goal');
  });

  test('updateGoal returns fallback model when response body is empty', () async {
    when(
      () => apiClient.patch(ApiEndpoints.updateGoalUrl('g1'), data: any(named: 'data')),
    ).thenAnswer((_) async => buildResponse(statusCode: 200, data: null));

    final result = await service.updateGoal(
      id: 'g1',
      name: 'Updated goal',
      targetAmount: 200,
      currentAmount: 40,
      backgroundColor: '#FFEEAA',
      icon: 'star',
      dueDate: DateTime.parse('2026-12-31T00:00:00Z'),
      note: 'updated note',
      status: GoalStatus.completed,
    );

    expect(result.id, 'g1');
    expect(result.name, 'Updated goal');
    expect(result.status, GoalStatus.completed);
  });

  test('deleteGoal throws when id is empty', () async {
    expect(() => service.deleteGoal('   '), throwsException);
  });

  test('deleteGoal returns true for successful response', () async {
    when(() => apiClient.delete(ApiEndpoints.deleteGoalUrl('g1'))).thenAnswer(
      (_) async => buildResponse(statusCode: 204, data: null),
    );

    final result = await service.deleteGoal('g1');

    expect(result, isTrue);
  });

  group('dio errors', () {
    test('maps badResponse with map payload', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.goals,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        buildDioException(
          type: DioExceptionType.badResponse,
          statusCode: 500,
          data: {'message': 'server down'},
        ),
      );

      expect(() => service.getGoals(pageSize: 100), throwsA(isA<Exception>()));
    });

    test('maps badResponse with string payload', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.goals,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        buildDioException(
          type: DioExceptionType.badResponse,
          statusCode: 500,
          data: 'plain failure',
        ),
      );

      expect(() => service.getGoals(pageSize: 100), throwsA(isA<Exception>()));
    });

    test('maps connectionTimeout', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.goals,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        buildDioException(
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(() => service.getGoals(pageSize: 100), throwsA(isA<Exception>()));
    });

    test('maps receiveTimeout', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.goals,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        buildDioException(
          type: DioExceptionType.receiveTimeout,
        ),
      );

      expect(() => service.getGoals(pageSize: 100), throwsA(isA<Exception>()));
    });

    test('maps cancel and network errors', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.goals,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        buildDioException(
          type: DioExceptionType.cancel,
        ),
      );

      expect(() => service.getGoals(pageSize: 100), throwsA(isA<Exception>()));

      when(
        () => apiClient.get(
          ApiEndpoints.goals,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        buildDioException(
          type: DioExceptionType.unknown,
          message: 'socket closed',
        ),
      );

      expect(() => service.getGoals(pageSize: 100), throwsA(isA<Exception>()));
    });
  });
}
