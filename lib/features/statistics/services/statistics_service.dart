import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/features/statistics/models/statistics_model.dart';

/// Service để gọi API liên quan đến Statistics
class StatisticsService {
  StatisticsService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

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

  /// Xử lý Dio errors
  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      print('Dio error response: ${e.response?.statusCode}');
      print('Dio error data: ${e.response?.data}');
      return Exception('API Error: ${e.response?.statusCode} - ${e.response?.data}');
    } else {
      print('Dio error: ${e.message}');
      return Exception('Network Error: ${e.message}');
    }
  }

  /// Lấy thống kê theo khoảng thời gian
  /// GET /Statistics
  /// 
  /// [from] - Thời điểm bắt đầu (mặc định: đầu tháng hiện tại)
  /// [to] - Thời điểm kết thúc (mặc định: hiện tại)
  Future<StatisticsResponseModel> getStatistics({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      // Nếu không có from, lấy ngày đầu tháng hiện tại
      final rawFromDate = from ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
      // Nếu không có to, lấy thời điểm hiện tại
      final rawToDate = to ?? DateTime.now();

      final fromDate = _startOfDay(rawFromDate);
      final toDate = to == null ? rawToDate : _endOfDay(rawToDate);

      final queryParams = <String, dynamic>{
        'From': fromDate.toUtc().toIso8601String(),
        'To': toDate.toUtc().toIso8601String(),
      };

      print('=== Get Statistics ===');
      print('URL: ${ApiEndpoints.statistics}');
      print('Query params: $queryParams');

      final response = await _api.get(
        ApiEndpoints.statistics,
        queryParameters: queryParams,
      );

      print('=== Get Statistics Response ===');
      print('Status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return StatisticsResponseModel.fromJson(_convertToMap(response.data));
      } else {
        throw Exception('Failed to get statistics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Export báo cáo thống kê
  /// Tùy thuộc vào API backend, có thể trả về file PDF, Excel, etc.
  /// Hiện tại implement placeholder
  Future<void> exportReport({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final rawFromDate = from ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
      final rawToDate = to ?? DateTime.now();

      final fromDate = _startOfDay(rawFromDate);
      final toDate = to == null ? rawToDate : _endOfDay(rawToDate);

      final queryParams = <String, dynamic>{
        'From': fromDate.toUtc().toIso8601String(),
        'To': toDate.toUtc().toIso8601String(),
      };

      print('=== Export Statistics Report ===');
      print('Query params: $queryParams');

      // TODO: Implement API export report khi backend có endpoint
      // Có thể download file PDF, Excel, etc.
      throw UnimplementedError('Export report chưa được implement trong backend');
    } catch (e) {
      print('Export error: $e');
      rethrow;
    }
  }
}
