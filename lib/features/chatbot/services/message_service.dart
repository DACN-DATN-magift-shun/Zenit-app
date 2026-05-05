import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/features/chatbot/models/chat_models.dart';

class MessageService {
  MessageService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

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

  Future<SendMessageResponse?> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.messages,
        data: {'conversationId': conversationId, 'text': text},
      );

      if (_isSuccessStatus(response.statusCode)) {
        final payload = _unwrapData(response.data);
        final data = _convertToMap(payload);
        if (data.isEmpty) {
          return null;
        }

        return SendMessageResponse.fromJson(data);
      }

      throw Exception('Failed to send message: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<MessageListResponse> getMessages({
    required String conversationId,
    required int pageSize,
  }) async {
    try {
      final response = await _api.get(
        ApiEndpoints.messages,
        queryParameters: {
          'ConversationId': conversationId,
          'PageSize': pageSize,
        },
      );

      if (response.statusCode == 200) {
        return MessageListResponse.fromJson(_unwrapData(response.data));
      }

      throw Exception('Failed to load messages: ${response.statusCode}');
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
