import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category.dart';

class CategoryService {
  final _apiClient = ApiClient();

  /// Fetch all categories from the API
  /// Returns a list of Category objects
  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.categories);
      return _parseCategoriesResponse(response);
    } catch (e) {
      print('Error loading categories: $e');
      rethrow;
    }
  }

  /// Parse the API response to extract categories
  /// Handles different response formats:
  /// - Direct list: [{"id": 1, "name": "Category1"}, ...]
  /// - Nested in data: {"data": [{"id": 1, "name": "Category1"}, ...]}
  /// - Nested in data.categories: {"data": {"categories": [...]}}
  List<Category> _parseCategoriesResponse(Response response) {
    final data = response.data;

    // If response data is null, return empty list
    if (data == null) {
      return [];
    }

    // Case 1: Direct list of categories
    if (data is List) {
      return _parseListToCategories(data);
    }

    // Case 2: Data is a Map
    if (data is Map<String, dynamic>) {
      // Try to get 'data' field first (common API pattern)
      final innerData = data['data'];

      if (innerData != null) {
        // Case 2a: data.data is a list
        if (innerData is List) {
          return _parseListToCategories(innerData);
        }

        // Case 2b: data.data is a map with 'categories' field
        if (innerData is Map<String, dynamic>) {
          final categories = innerData['categories'];
          if (categories is List) {
            return _parseListToCategories(categories);
          }
        }
      }

      // Case 2c: categories directly in data map
      final categories = data['categories'];
      if (categories is List) {
        return _parseListToCategories(categories);
      }
    }

    // If we can't parse the response, return empty list
    print('Warning: Unable to parse categories from response format');
    return [];
  }

  /// Safely parse a list of dynamic items to Category objects
  /// This method properly iterates over the list using int indices
  List<Category> _parseListToCategories(List<dynamic> items) {
    final List<Category> categories = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item is Map<String, dynamic>) {
        try {
          categories.add(Category.fromJson(item));
        } catch (e) {
          print('Error parsing category at index $i: $e');
        }
      }
    }

    return categories;
  }

  /// Fetch a single category by ID
  Future<Category?> getCategoryById(String id) async {
    try {
      final response = await _apiClient.dio.get('${ApiEndpoints.categories}/$id');
      final data = response.data;

      if (data is Map<String, dynamic>) {
        // Handle nested data structure
        final categoryData = data['data'] ?? data;
        if (categoryData is Map<String, dynamic>) {
          return Category.fromJson(categoryData);
        }
      }
      return null;
    } catch (e) {
      print('Error loading category $id: $e');
      rethrow;
    }
  }

  /// Create a new category
  Future<Category?> createCategory({
    required String name,
    String? description,
    String? icon,
    String? color,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.categories,
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (icon != null) 'icon': icon,
          if (color != null) 'color': color,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final categoryData = data['data'] ?? data;
        if (categoryData is Map<String, dynamic>) {
          return Category.fromJson(categoryData);
        }
      }
      return null;
    } catch (e) {
      print('Error creating category: $e');
      rethrow;
    }
  }

  /// Update an existing category
  Future<Category?> updateCategory({
    required String id,
    String? name,
    String? description,
    String? icon,
    String? color,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiEndpoints.categories}/$id',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (icon != null) 'icon': icon,
          if (color != null) 'color': color,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final categoryData = data['data'] ?? data;
        if (categoryData is Map<String, dynamic>) {
          return Category.fromJson(categoryData);
        }
      }
      return null;
    } catch (e) {
      print('Error updating category $id: $e');
      rethrow;
    }
  }

  /// Delete a category by ID
  Future<bool> deleteCategory(String id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.categories}/$id');
      return true;
    } catch (e) {
      print('Error deleting category $id: $e');
      return false;
    }
  }
}
