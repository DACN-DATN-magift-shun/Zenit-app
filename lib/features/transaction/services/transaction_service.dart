import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/features/transaction/models/transaction_model.dart';

/// Service để gọi API liên quan đến Transaction
class TransactionService {
  TransactionService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  /// Helper để convert response data sang Map<String, dynamic> an toàn
  Map<String, dynamic> _convertToMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
      return Map<String, dynamic>.from(data);
    } else if (data is String) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return {};
  }

  /// Lấy danh sách transactions với phân trang
  /// GET /Transactions
  Future<TransactionListResponse> getAllTransactions({
    DateTime? fromDate,
    DateTime? toDate,
    String? categoryId,
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
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['CategoryId'] = categoryId;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['Search'] = search;
      }
      if (beforeId != null && beforeId.isNotEmpty) {
        queryParams['BeforeId'] = beforeId;
      }

      print('=== Get All Transactions ===');
      print('URL: ${ApiEndpoints.transactions}');
      print('Query params: $queryParams');

      final response = await _api.get(
        ApiEndpoints.transactions,
        queryParameters: queryParams,
      );

      print('=== Get All Transactions Response ===');
      print('Status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return TransactionListResponse.fromJson(_convertToMap(response.data));
      } else {
        throw Exception('Failed to get transactions: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Tạo transaction mới
  /// POST /Transactions
  Future<TransactionModel> createTransaction({
    required String title,
    String? note,
    required int amount,
    required DateTime transactionDate,
    required String categoryId,
    required String walletId,
  }) async {
    try {
      final requestData = {
        'title': title,
        'note': note ?? '',
        'amount': amount,
        'transactionDate': transactionDate.toUtc().toIso8601String(),
        'categoryId': categoryId,
        'walletId': walletId,
      };

      print('=== Create Transaction Request ===');
      print('URL: ${ApiEndpoints.createTransaction}');
      print('Request data: $requestData');

      final response = await _api.post(
        ApiEndpoints.createTransaction,
        data: requestData,
      );

      print('=== Create Transaction Response ===');
      print('Status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TransactionModel.fromJson(_convertToMap(response.data));
      } else {
        throw Exception('Failed to create transaction: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Cập nhật một hoặc nhiều transaction
  /// PATCH /Transactions
  Future<bool> updateTransactions(List<TransactionModel> transactions) async {
    try {
      final requestData = {
        'transactions': transactions
            .map((transaction) => transaction.toJsonWithId())
            .toList(),
      };

      print('=== Update Transactions Request ===');
      print('URL: ${ApiEndpoints.transactions}');
      print('Request data: $requestData');

      final response = await _api.patch(
        ApiEndpoints.transactions,
        data: requestData,
      );

      print('=== Update Transactions Response ===');
      print('Status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return true;
      }

      throw Exception('Failed to update transactions: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Lấy một transaction theo ID
  /// GET /Transactions/{id}
  Future<TransactionModel> getTransactionById(String id) async {
    try {
      print('=== Get Transaction By ID ===');
      print('URL: ${ApiEndpoints.transactionById(id)}');

      final response = await _api.get(ApiEndpoints.transactionById(id));

      print('=== Get Transaction Response ===');
      print('Status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return TransactionModel.fromJson(_convertToMap(response.data));
      } else {
        throw Exception('Failed to get transaction: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Xóa transaction theo ID
  /// DELETE /Transactions/{id}
  Future<bool> deleteTransaction(String id) async {
    try {
      print('=== Delete Transaction ===');
      print('URL: ${ApiEndpoints.deleteTransactionUrl(id)}');

      final response = await _api.delete(ApiEndpoints.deleteTransactionUrl(id));

      print('=== Delete Transaction Response ===');
      print('Status code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete transaction: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Helper để xử lý lỗi Dio
  Exception _handleDioError(DioException e) {
    print('=== DioException ===');
    print('Type: ${e.type}');
    print('Message: ${e.message}');
    print('Response: ${e.response?.data}');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Kết nối timeout. Vui lòng thử lại.');
      case DioExceptionType.sendTimeout:
        return Exception('Gửi request timeout. Vui lòng thử lại.');
      case DioExceptionType.receiveTimeout:
        return Exception('Nhận response timeout. Vui lòng thử lại.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Có lỗi xảy ra';
        return Exception('Lỗi $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('Request đã bị hủy.');
      case DioExceptionType.connectionError:
        return Exception(
          'Không thể kết nối đến server. Vui lòng kiểm tra mạng.',
        );
      default:
        return Exception('Có lỗi xảy ra. Vui lòng thử lại.');
    }
  }
}
