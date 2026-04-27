import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/features/goals/models/goal_model.dart';

class GoalsService {
  GoalsService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  bool _isSuccessStatus(int? statusCode) {
    return statusCode == 200 ||
        statusCode == 201 ||
        statusCode == 202 ||
        statusCode == 204;
  }

  Map<String, dynamic> _convertToMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return {};
  }

  List<GoalModel> _convertToList(dynamic data) {
    if (data is List) {
      return data.map((item) => GoalModel.fromJson(item)).toList();
    }

    final json = _convertToMap(data);

    final items = json['items'];
    if (items is List) {
      return items.map((item) => GoalModel.fromJson(item)).toList();
    }

    final goals = json['goals'];
    if (goals is List) {
      return goals.map((item) => GoalModel.fromJson(item)).toList();
    }

    final nestedData = _convertToMap(json['data']);
    final nestedItems = nestedData['items'];
    if (nestedItems is List) {
      return nestedItems.map((item) => GoalModel.fromJson(item)).toList();
    }

    if (json.containsKey('id') || json.containsKey('name')) {
      return [GoalModel.fromJson(json)];
    }

    return [];
  }

  Future<List<GoalModel>> getGoals({
    String? search,
    String? beforeId,
    int pageSize = 100,
    bool useCountTotal = false,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'PageSize': pageSize};

      if (search != null && search.trim().isNotEmpty) {
        queryParameters['Search'] = search.trim();
      }
      if (beforeId != null && beforeId.trim().isNotEmpty) {
        queryParameters['BeforeId'] = beforeId.trim();
      }
      if (useCountTotal) {
        queryParameters['UseCountTotal'] = true;
      }

      final response = await _api.get(
        ApiEndpoints.goals,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return _convertToList(response.data);
      }

      throw Exception('Failed to load goals: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<GoalModel> getGoalById(String id) async {
    try {
      final response = await _api.get(ApiEndpoints.goalById(id));

      if (response.statusCode == 200) {
        return GoalModel.fromJson(_convertToMap(response.data));
      }

      throw Exception('Failed to load goal detail: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<GoalModel> createGoal({
    required String name,
    required int targetAmount,
    required int currentAmount,
    required String backgroundColor,
    required String icon,
    required DateTime dueDate,
    required String note,
    required GoalStatus status,
  }) async {
    try {
      final requestData = {
        'name': name,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'backgroundColor': backgroundColor,
        'icon': icon,
        'dueDate': dueDate.toUtc().toIso8601String(),
        'note': note,
        'status': status.value,
      };

      final response = await _api.post(
        ApiEndpoints.createGoal,
        data: requestData,
      );

      if (_isSuccessStatus(response.statusCode)) {
        final responseMap = _convertToMap(response.data);
        if (responseMap.isNotEmpty) {
          return GoalModel.fromJson(responseMap);
        }

        return GoalModel(
          id: '',
          name: name,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          backgroundColor: backgroundColor,
          icon: icon,
          createdAt: DateTime.now(),
          dueDate: dueDate,
          note: note,
          status: status,
        );
      }

      throw Exception('Failed to create goal: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<GoalModel> updateGoal({
    required String id,
    String? name,
    int? targetAmount,
    int? currentAmount,
    String? backgroundColor,
    String? icon,
    DateTime? dueDate,
    String? note,
    GoalStatus? status,
  }) async {
    try {
      final requestData = <String, dynamic>{'id': id};

      if (name != null) requestData['name'] = name;
      if (targetAmount != null) requestData['targetAmount'] = targetAmount;
      if (currentAmount != null) requestData['currentAmount'] = currentAmount;
      if (backgroundColor != null) requestData['backgroundColor'] = backgroundColor;
      if (icon != null) requestData['icon'] = icon;
      if (dueDate != null) {
        requestData['dueDate'] = dueDate.toUtc().toIso8601String();
      }
      if (note != null) requestData['note'] = note;
      if (status != null) requestData['status'] = status.value;

      final response = await _api.patch(
        ApiEndpoints.updateGoalUrl(id),
        data: requestData,
      );

      if (_isSuccessStatus(response.statusCode)) {
        final responseMap = _convertToMap(response.data);
        if (responseMap.isNotEmpty) {
          return GoalModel.fromJson(responseMap);
        }

        return GoalModel(
          id: id,
          name: name ?? '',
          targetAmount: targetAmount ?? 0,
          currentAmount: currentAmount ?? 0,
          backgroundColor: backgroundColor ?? '#D2E4FF',
          icon: icon ?? 'flag',
          createdAt: DateTime.now(),
          dueDate: dueDate ?? DateTime.now(),
          note: note ?? '',
          status: status ?? GoalStatus.ongoing,
        );
      }

      throw Exception('Failed to update goal: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<bool> deleteGoal(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('Cannot delete goal because id is missing.');
    }

    try {
      final response = await _api.delete(ApiEndpoints.deleteGoalUrl(id));
      return _isSuccessStatus(response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.receiveTimeout:
        return Exception('Server is taking too long to respond.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        String message = 'Unknown error';
        if (responseData is Map<String, dynamic>) {
          message = responseData['message']?.toString() ?? message;
        } else if (responseData is String && responseData.isNotEmpty) {
          message = responseData;
        }
        return Exception('Server error ($statusCode): $message');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      default:
        return Exception('Network error: ${e.message}');
    }
  }
}
