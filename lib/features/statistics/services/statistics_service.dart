import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
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

  /// Helper để convert response data sang map an toàn
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
      debugPrint('Dio error response: ${e.response?.statusCode}');
      debugPrint('Dio error data: ${e.response?.data}');
      return Exception('API Error: ${e.response?.statusCode} - ${e.response?.data}');
    } else {
      debugPrint('Dio error: ${e.message}');
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

      debugPrint('=== Get Statistics ===');
      debugPrint('URL: ${ApiEndpoints.statistics}');
      debugPrint('Query params: $queryParams');

      final response = await _api.get(
        ApiEndpoints.statistics,
        queryParameters: queryParams,
      );

      debugPrint('=== Get Statistics Response ===');
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

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
        'FromDate': fromDate.toUtc().toIso8601String(),
        'ToDate': toDate.toUtc().toIso8601String(),
      };

      debugPrint('=== Export Statistics Report ===');
      debugPrint('URL: ${ApiEndpoints.statisticsReports}');
      debugPrint('Query params: $queryParams');

      final response = await _api.post(
        ApiEndpoints.statisticsReports,
        queryParameters: queryParams,
        options: Options(headers: const {'accept': '*/*'}),
      );

      debugPrint('=== Export Statistics Report Response ===');
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to export report: ${response.statusCode}');
      }

      final responseData = _convertToMap(response.data);
      final reportUrl = responseData['reportUrl']?.toString();

      if (reportUrl == null || reportUrl.isEmpty) {
        throw Exception('Report URL is missing in response');
      }

      final reportUri = Uri.tryParse(reportUrl);
      if (reportUri == null) {
        throw Exception('Invalid report URL: $reportUrl');
      }

      final didLaunch = await launchUrl(
        reportUri,
        mode: LaunchMode.externalApplication,
      );

      if (!didLaunch) {
        throw Exception('Unable to open report URL');
      }
    } catch (e) {
      debugPrint('Export error: $e');
      rethrow;
    }
  }
}
