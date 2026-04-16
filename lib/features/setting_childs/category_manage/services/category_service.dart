import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';

/// Service để gọi API liên quan đến Category
class CategoryService {
  final _api = ApiClient();

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

  /// Lấy danh sách categories theo groupType
  /// GET /Categories?groupType={groupType}
  Future<CategoryGroup> getCategoriesByGroupType(int groupType) async {
    try {
      print('=== Calling API ===');
      print('URL: ${ApiEndpoints.categories}');
      print('Query params: {groupType: $groupType}');

      final response = await _api.get(
        ApiEndpoints.categories,
        queryParameters: {'groupType': groupType},
      );

      print('=== API Response for groupType $groupType ===');
      print('Status code: ${response.statusCode}');
      print('Response data: ${response.data}');
      print('Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        final rawData = response.data;

        // Handle case when API returns a List
        if (rawData is List) {
          return CategoryGroup(
            name: GroupType.fromValue(groupType).displayName,
            type: groupType,
            categories: rawData
                .map((e) => CategoryModel.fromJson(_convertToMap(e)))
                .toList(),
          );
        }

        // Handle object payloads where categories can be nested under
        // different keys depending on backend response shape.
        final data = _convertToMap(rawData);
        final nestedCategories =
            data['categories'] ?? data['data'] ?? data['items'];
        if (nestedCategories is List) {
          return CategoryGroup(
            name: GroupType.fromValue(groupType).displayName,
            type: groupType,
            categories: nestedCategories
                .map((e) => CategoryModel.fromJson(_convertToMap(e)))
                .toList(),
          );
        }

        // Fallback to generic parser but enforce queried groupType to keep
        // keys stable for UI filtering (expense/income mode).
        final parsedGroup = CategoryGroup.fromJson(data);
        return parsedGroup.copyWith(
          name: parsedGroup.name.isEmpty
              ? GroupType.fromValue(groupType).displayName
              : parsedGroup.name,
          type: groupType,
        );
      } else {
        // Return empty group for non-200 responses
        return CategoryGroup(
          name: GroupType.fromValue(groupType).displayName,
          type: groupType,
          categories: [],
        );
      }
    } on DioException catch (e) {
      // Handle 404 - return empty group instead of throwing
      if (e.response?.statusCode == 404) {
        return CategoryGroup(
          name: GroupType.fromValue(groupType).displayName,
          type: groupType,
          categories: [],
        );
      }
      throw _handleDioError(e);
    }
  }

  /// Lấy tất cả categories của tất cả groupType (0-5)
  /// Gọi song song 6 API để lấy nhanh hơn
  Future<Map<int, CategoryGroup>> getAllCategoriesByAllGroups() async {
    try {
      final futures = <Future<CategoryGroup>>[];

      // Tạo 6 request song song cho groupType 0-5
      for (int i = 0; i <= 5; i++) {
        futures.add(getCategoriesByGroupType(i));
      }

      final results = await Future.wait(futures);

      // Convert thành Map<groupType, CategoryGroup>
      final Map<int, CategoryGroup> groupMap = {};
      for (var group in results) {
        groupMap[group.type] = group;
      }

      return groupMap;
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy một category theo ID
  /// GET /Categories/{id}
  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final response = await _api.get(ApiEndpoints.categoryById(id));

      if (response.statusCode == 200) {
        // API trả về category object trực tiếp
        return CategoryModel.fromJson(_convertToMap(response.data));
      } else {
        throw Exception('Failed to load category: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Tạo category mới
  /// POST /Categories
  Future<CategoryModel> createCategory({
    required String name,
    required String icon,
    required String color,
    required String backgroundColor,
    required int groupType,
    double expenseLimit = 0,
    double expenseAlertThreshold = 0,
  }) async {
    try {
      final requestData = {
        'name': name,
        'icon': icon,
        'color': color,
        'backgroundColor': backgroundColor,
        'expenseLimit': expenseLimit.toInt(),
        'expenseAlertThreshold': expenseAlertThreshold.toInt(),
        'groupType': groupType,
      };

      print('=== Create Category Request ===');
      print('URL: ${ApiEndpoints.createCategory}');
      print('Request data: $requestData');

      final response = await _api.post(
        ApiEndpoints.createCategory,
        data: requestData,
      );

      print('=== Create Category Response ===');
      print('Status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CategoryModel.fromJson(_convertToMap(response.data));
      } else {
        throw Exception('Failed to create category: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('=== Create Category Error ===');
      print('Error response: ${e.response?.data}');
      print('Error status: ${e.response?.statusCode}');
      throw _handleDioError(e);
    }
  }

  /// Cập nhật category
  /// PATCH /Categories/{id}
  Future<CategoryModel> updateCategory({
    required String id,
    required String name,
    required String icon,
    required String color,
    required String backgroundColor,
    required int groupType,
    double expenseLimit = 0,
    double expenseAlertThreshold = 0,
  }) async {
    try {
      final requestData = {
        'id': id,
        'name': name,
        'icon': icon,
        'color': color,
        'backgroundColor': backgroundColor,
        'expenseLimit': expenseLimit.toInt(),
        'expenseAlertThreshold': expenseAlertThreshold.toInt(),
        'groupType': groupType,
      };

      print('=== Update Category Request ===');
      print('URL: ${ApiEndpoints.updateCategoryUrl(id)}');
      print('Request data: $requestData');

      final response = await _api.patch(
        ApiEndpoints.updateCategoryUrl(id),
        data: requestData,
      );

      print('=== Update Category Response ===');
      print('Status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = _convertToMap(response.data);
        // Kiểm tra xem response có chứa error hay không (BE có thể trả 200 với error message)
        if (data.containsKey('code') && data['code'] != null) {
          final errorCode = data['code'];
          final details = data['details']?.toString().trim();
          final message = data['message']?.toString().trim();
          final errorMessage = (details != null && details.isNotEmpty)
              ? details
              : ((message != null && message.isNotEmpty)
                    ? message
                    : 'Unknown error');
          print('=== Error in 200 Response ===');
          print('Error code: $errorCode');
          print('Error message: $errorMessage');
          throw Exception(errorMessage);
        }
        return CategoryModel.fromJson(data);
      } else {
        throw Exception('Failed to update category: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Xóa một category theo ID
  /// DELETE /Categories/{id}
  Future<bool> deleteCategory(String id) async {
    try {
      final response = await _api.delete(ApiEndpoints.deleteCategoryUrl(id));

      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Xóa nhiều categories (bulk delete)
  /// DELETE /Categories với body { "ids": [...] }
  Future<bool> deleteCategories(List<String> ids) async {
    try {
      final response = await _api.delete(
        ApiEndpoints.deleteCategories,
        data: {'ids': ids},
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Xử lý lỗi Dio
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
        String message = 'Unknown error';
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          message = responseData['message']?.toString() ?? 'Unknown error';
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
