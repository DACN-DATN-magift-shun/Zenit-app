import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/features/loans/models/loan_model.dart';

class LoansService {
  final _api = ApiClient();

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

  List<LoanModel> _convertToList(dynamic data) {
    if (data is List) {
      return data.map((item) => LoanModel.fromJson(item)).toList();
    }

    final json = _convertToMap(data);

    final items = json['items'];
    if (items is List) {
      return items.map((item) => LoanModel.fromJson(item)).toList();
    }

    final loans = json['loans'];
    if (loans is List) {
      return loans.map((item) => LoanModel.fromJson(item)).toList();
    }

    final nestedData = _convertToMap(json['data']);
    final nestedItems = nestedData['items'];
    if (nestedItems is List) {
      return nestedItems.map((item) => LoanModel.fromJson(item)).toList();
    }

    if (json.containsKey('id') || json.containsKey('name')) {
      return [LoanModel.fromJson(json)];
    }

    return [];
  }

  Future<List<LoanModel>> getLoans({
    int? type,
    String? search,
    String? beforeId,
    int pageSize = 100,
    bool useCountTotal = false,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'PageSize': pageSize};

      if (type != null) {
        queryParameters['Type'] = type;
      }
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
        ApiEndpoints.loans,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return _convertToList(response.data);
      }

      throw Exception('Failed to load loans: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<LoanModel> getLoanById(String id) async {
    try {
      final response = await _api.get(ApiEndpoints.loanById(id));

      if (response.statusCode == 200) {
        return LoanModel.fromJson(_convertToMap(response.data));
      }

      throw Exception('Failed to load loan detail: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<LoanModel> createLoan({
    required String name,
    required int type,
    required int amount,
    required DateTime date,
    required DateTime dueDate,
    String note = '',
  }) async {
    try {
      final requestData = {
        'name': name,
        'type': type,
        'amount': amount,
        'date': date.toUtc().toIso8601String(),
        'dueDate': dueDate.toUtc().toIso8601String(),
        'note': note,
      };

      final response = await _api.post(
        ApiEndpoints.createLoan,
        data: requestData,
      );

      if (_isSuccessStatus(response.statusCode)) {
        final responseMap = _convertToMap(response.data);
        if (responseMap.isNotEmpty) {
          return LoanModel.fromJson(responseMap);
        }

        return LoanModel(
          id: '',
          name: name,
          type: type,
          amount: amount,
          date: date,
          dueDate: dueDate,
          note: note,
        );
      }

      throw Exception('Failed to create loan: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<LoanModel> updateLoan({
    required String id,
    String? name,
    int? type,
    int? amount,
    DateTime? date,
    DateTime? dueDate,
    String? note,
  }) async {
    try {
      final requestData = <String, dynamic>{'id': id};

      if (name != null) requestData['name'] = name;
      if (type != null) requestData['type'] = type;
      if (amount != null) requestData['amount'] = amount;
      if (date != null) requestData['date'] = date.toUtc().toIso8601String();
      if (dueDate != null) {
        requestData['dueDate'] = dueDate.toUtc().toIso8601String();
      }
      if (note != null) requestData['note'] = note;

      final response = await _api.patch(
        ApiEndpoints.updateLoanUrl(id),
        data: requestData,
      );

      if (_isSuccessStatus(response.statusCode)) {
        final responseMap = _convertToMap(response.data);
        if (responseMap.isNotEmpty) {
          return LoanModel.fromJson(responseMap);
        }

        return LoanModel(
          id: id,
          name: name ?? '',
          type: type ?? 0,
          amount: amount ?? 0,
          date: date ?? DateTime.now(),
          dueDate: dueDate ?? date ?? DateTime.now(),
          note: note ?? '',
        );
      }

      throw Exception('Failed to update loan: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<bool> deleteLoan(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('Cannot delete loan because id is missing.');
    }

    try {
      final response = await _api.delete(ApiEndpoints.deleteLoanUrl(id));
      return _isSuccessStatus(response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<bool> createManyLoans(List<LoanModel> loans) async {
    try {
      final response = await _api.post(
        ApiEndpoints.createManyLoans,
        data: {'loans': loans.map((loan) => loan.toCreateJson()).toList()},
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
