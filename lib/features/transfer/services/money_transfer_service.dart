import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/features/transfer/models/money_transfer_model.dart';

class MoneyTransferService {
  MoneyTransferService({ApiClient? apiClient})
    : _api = apiClient ?? ApiClient();

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

  Future<MoneyTransferListResponse> getMoneyTransfers({
    DateTime? fromDate,
    DateTime? toDate,
    String? search,
    String? beforeId,
    required int pageSize,
    bool useCountTotal = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'PageSize': pageSize,
        'UseCountTotal': useCountTotal,
      };

      if (fromDate != null) {
        queryParams['FromDate'] = fromDate.toUtc().toIso8601String();
      }
      if (toDate != null) {
        queryParams['ToDate'] = toDate.toUtc().toIso8601String();
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['Search'] = search.trim();
      }
      if (beforeId != null && beforeId.trim().isNotEmpty) {
        queryParams['BeforeId'] = beforeId.trim();
      }

      final response = await _api.get(
        ApiEndpoints.moneyTransfers,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return MoneyTransferListResponse.fromJson(_convertToMap(response.data));
      }

      throw Exception('Failed to load transfers: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<MoneyTransferModel> getMoneyTransferById(String id) async {
    try {
      final response = await _api.get(ApiEndpoints.moneyTransferById(id));

      if (response.statusCode == 200) {
        return MoneyTransferModel.fromJson(_convertToMap(response.data));
      }

      throw Exception('Failed to load transfer detail: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<MoneyTransferModel> createMoneyTransfer({
    required String fromWalletId,
    required String toWalletId,
    required int amount,
    required DateTime transferDate,
    String note = '',
  }) async {
    try {
      final payload = {
        'fromWalletId': fromWalletId,
        'toWalletId': toWalletId,
        'amount': amount,
        'transferDate': transferDate.toUtc().toIso8601String(),
        'note': note,
      };

      final response = await _api.post(
        ApiEndpoints.createMoneyTransfer,
        data: payload,
      );

      if (_isSuccessStatus(response.statusCode)) {
        final responseMap = _convertToMap(response.data);
        if (responseMap.isNotEmpty) {
          return MoneyTransferModel.fromJson(responseMap);
        }

        return MoneyTransferModel(
          id: '',
          fromWalletId: fromWalletId,
          toWalletId: toWalletId,
          amount: amount,
          transferDate: transferDate,
          note: note,
        );
      }

      throw Exception('Failed to create transfer: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<MoneyTransferModel> updateMoneyTransfer({
    required String id,
    required String fromWalletId,
    required String toWalletId,
    required int amount,
    required DateTime transferDate,
    required String note,
  }) async {
    try {
      final payload = {
        'id': id,
        'fromWalletId': fromWalletId,
        'toWalletId': toWalletId,
        'amount': amount,
        'transferDate': transferDate.toUtc().toIso8601String(),
        'note': note,
      };

      final response = await _api.patch(
        ApiEndpoints.updateMoneyTransferUrl(id),
        data: payload,
      );

      if (_isSuccessStatus(response.statusCode)) {
        final responseMap = _convertToMap(response.data);
        if (responseMap.isNotEmpty) {
          return MoneyTransferModel.fromJson(responseMap);
        }

        return MoneyTransferModel(
          id: id,
          fromWalletId: fromWalletId,
          toWalletId: toWalletId,
          amount: amount,
          transferDate: transferDate,
          note: note,
        );
      }

      throw Exception('Failed to update transfer: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<bool> deleteMoneyTransfer(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('Cannot delete transfer because id is missing.');
    }

    try {
      final response = await _api.delete(
        ApiEndpoints.deleteMoneyTransferUrl(id),
      );
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
