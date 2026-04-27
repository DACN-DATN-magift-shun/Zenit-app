import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';

class MoneySourceService {
  MoneySourceService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  bool _isSuccessStatus(int? statusCode) {
    return statusCode == 200 || statusCode == 202 || statusCode == 204;
  }

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

  List<MoneySourceModel> _convertToList(dynamic data) {
    if (data is List) {
      return data.map((item) => MoneySourceModel.fromJson(item)).toList();
    }

    final json = _convertToMap(data);
    final items = json['items'];
    if (items is List) {
      return items.map((item) => MoneySourceModel.fromJson(item)).toList();
    }

    final nestedData = _convertToMap(json['data']);
    final nestedItems = nestedData['items'];
    if (nestedItems is List) {
      return nestedItems
          .map((item) => MoneySourceModel.fromJson(item))
          .toList();
    }

    final wallets = json['wallets'];
    if (wallets is List) {
      return wallets.map((item) => MoneySourceModel.fromJson(item)).toList();
    }

    // Fallback for APIs that return a single wallet object.
    if (json.containsKey('name') || json.containsKey('icon')) {
      return [MoneySourceModel.fromJson(json)];
    }

    return [];
  }

  Future<List<MoneySourceModel>> getAllMoneySources() async {
    try {
      final response = await _api.get(
        ApiEndpoints.wallets,
        queryParameters: const {'PageSize': 100},
      );

      if (response.statusCode == 200) {
        return _convertToList(response.data);
      }

      throw Exception('Failed to load money sources: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<MoneySourceModel> getMoneySourceById(String id) async {
    try {
      final response = await _api.get(ApiEndpoints.walletById(id));

      if (response.statusCode == 200) {
        return MoneySourceModel.fromJson(_convertToMap(response.data));
      }

      throw Exception(
        'Failed to load money source detail: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<MoneySourceModel> createMoneySource({
    required String name,
    required String icon,
    required String backgroundColorHex,
    int amount = 0,
    String note = '',
    bool isIncludeInTotalBalance = true,
  }) async {
    try {
      final requestData = {
        'name': name,
        'amount': amount,
        'backgroundColor': backgroundColorHex,
        'icon': icon,
        'note': note,
        'isIncludeInTotalBalance': isIncludeInTotalBalance,
      };

      final response = await _api.post(
        ApiEndpoints.createWallet,
        data: requestData,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        final responseMap = _convertToMap(response.data);
        if (responseMap.isNotEmpty) {
          return MoneySourceModel.fromJson(responseMap);
        }

        // Some backends return empty/ack payload for create.
        // Return a local model so caller can continue safely.
        return MoneySourceModel(
          id: '',
          name: name,
          amount: amount,
          iconName: icon,
          backgroundColorHex: backgroundColorHex,
          note: note,
          isIncludeInTotalBalance: isIncludeInTotalBalance,
        );
      }

      throw Exception('Failed to create money source: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<MoneySourceModel> updateMoneySource({
    required String id,
    required String name,
    required String icon,
    required String backgroundColorHex,
    int amount = 0,
    String note = '',
    bool isIncludeInTotalBalance = true,
  }) async {
    try {
      final requestData = {
        'id': id,
        'name': name,
        'amount': amount,
        'note': note,
        'backgroundColor': backgroundColorHex,
        'icon': icon,
        'isIncludeInTotalBalance': isIncludeInTotalBalance,
      };

      final response = await _api.patch(
        ApiEndpoints.updateWalletUrl(id),
        data: requestData,
      );

      if (response.statusCode == 200) {
        return MoneySourceModel.fromJson(_convertToMap(response.data));
      }

      throw Exception('Failed to update money source: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<bool> deleteMoneySource(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('Cannot delete wallet because wallet id is missing.');
    }

    try {
      final response = await _api.delete(ApiEndpoints.deleteWalletUrl(id));
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
