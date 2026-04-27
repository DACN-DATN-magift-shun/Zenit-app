import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/features/chatbot/models/chat_models.dart';

class ConversationService {
  ConversationService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

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
    if (data is String && data.isNotEmpty) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return {};
  }

  dynamic _unwrapData(dynamic raw) {
    final root = _convertToMap(raw);
    if (root['data'] != null) {
      return root['data'];
    }
    return root;
  }

  Future<ConversationSummary> createConversation({
    required String title,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.conversations,
        data: {'title': title},
      );

      if (_isSuccessStatus(response.statusCode)) {
        return ConversationSummary.fromJson(_unwrapData(response.data));
      }

      throw Exception('Failed to create conversation: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<ConversationListResponse> getConversations({
    required int pageSize,
    String? search,
    String? beforeId,
    bool useCountTotal = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'PageSize': pageSize,
        'UseCountTotal': useCountTotal,
      };

      if (search != null && search.trim().isNotEmpty) {
        queryParams['Search'] = search.trim();
      }
      if (beforeId != null && beforeId.trim().isNotEmpty) {
        queryParams['BeforeId'] = beforeId.trim();
      }

      final response = await _api.get(
        ApiEndpoints.conversations,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return ConversationListResponse.fromJson(_unwrapData(response.data));
      }

      throw Exception('Failed to load conversations: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<ConversationDetail> getConversationById(String id) async {
    try {
      final response = await _api.get(ApiEndpoints.conversationById(id));

      if (response.statusCode == 200) {
        return ConversationDetail.fromJson(_unwrapData(response.data));
      }

      throw Exception(
        'Failed to load conversation detail: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<ConversationSummary> updateConversationTitle({
    required String id,
    required String title,
  }) async {
    try {
      final response = await _api.patch(
        ApiEndpoints.conversationById(id),
        data: {'title': title},
      );

      if (_isSuccessStatus(response.statusCode)) {
        final payload = _unwrapData(response.data);
        final asMap = _convertToMap(payload);
        if (asMap.isNotEmpty) {
          return ConversationSummary.fromJson(asMap);
        }

        return ConversationSummary(
          id: id,
          title: title,
          updatedAt: DateTime.now(),
        );
      }

      throw Exception(
        'Failed to update conversation title: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<bool> deleteConversation(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('Cannot delete conversation because id is missing.');
    }

    try {
      final response = await _api.delete(ApiEndpoints.conversationById(id));
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
        if (message.toLowerCase().contains(
          'terminating connection due to administrator command',
        )) {
          return Exception(
            'Conversation service is restarting or unavailable. Please try again shortly.',
          );
        }
        return Exception('Server error ($statusCode): $message');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      default:
        return Exception('Network error: ${e.message}');
    }
  }
}
