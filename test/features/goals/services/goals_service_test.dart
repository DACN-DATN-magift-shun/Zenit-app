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

  test('getGoals parses list response', () async {
    when(
      () => apiClient.get(ApiEndpoints.goals, queryParameters: any(named: 'queryParameters')),
    ).thenAnswer((_) async => buildResponse(statusCode: 200, data: goalsListResponseData));

    final result = await service.getGoals(pageSize: 100);

    expect(result.length, 1);
    expect(result.first.id, 'g1');
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

  test('deleteGoal throws when id is empty', () async {
    expect(() => service.deleteGoal('   '), throwsException);
  });

  test('getGoals converts dio badResponse to domain exception', () async {
    when(
      () => apiClient.get(ApiEndpoints.goals, queryParameters: any(named: 'queryParameters')),
    ).thenThrow(buildDioException(
      type: DioExceptionType.badResponse,
      statusCode: 500,
      data: {'message': 'server down'},
    ));

    expect(() => service.getGoals(pageSize: 100), throwsA(isA<Exception>()));
  });
}
