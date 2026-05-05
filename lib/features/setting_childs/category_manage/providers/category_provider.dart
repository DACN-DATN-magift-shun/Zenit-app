import 'package:flutter/material.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/services/category_service.dart';

/// Provider quản lý state và CRUD cho Categories
/// Dữ liệu được tổ chức theo groupType (0-5) để dễ hiển thị trên UI
class CategoryProvider extends ChangeNotifier {
  CategoryProvider({CategoryService? categoryService})
    : _categoryService = categoryService ?? CategoryService();

  final CategoryService _categoryService;

  // State: Map lưu CategoryGroup theo groupType
  // Key: groupType (0-5), Value: CategoryGroup chứa danh sách categories
  Map<int, CategoryGroup> _categoryGroups = {};

  // Loading states
  bool _isLoading = false;
  bool _isActionLoading = false; // Loading cho các action CRUD
  String? _errorMessage;
  
  String _normalizeErrorMessage(Object error) {
    final raw = error.toString().trim();
    if (raw.startsWith('Exception: ')) {
      return raw.replaceFirst('Exception: ', '').trim();
    }
    return raw;
  }

  // Getters
  Map<int, CategoryGroup> get categoryGroups => _categoryGroups;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;

  /// Lấy CategoryGroup theo groupType
  CategoryGroup? getCategoryGroup(int groupType) => _categoryGroups[groupType];

  /// Lấy danh sách categories theo groupType
  List<CategoryModel> getCategoriesByGroupType(int groupType) {
    return _categoryGroups[groupType]?.categories ?? [];
  }

  /// Lấy tất cả categories từ mọi groupType dưới dạng một danh sách phẳng
  List<CategoryModel> get categories {
    return _categoryGroups.values
        .expand((group) => group.categories)
        .toList(growable: false);
  }

  /// Lấy tên của group theo groupType
  String getGroupName(int groupType) {
    return
        _categoryGroups[groupType]?.name ??
        GroupType.fromValue(groupType).displayName;
  }

  /// Lấy tổng số categories của tất cả groups
  int get totalCategories {
    return _categoryGroups.values.fold(
      0,
      (sum, group) => sum + group.categories.length,
    );
  }

  /// Kiểm tra xem đã load data chưa
  bool get hasData => _categoryGroups.isNotEmpty;

  // ==================== CRUD Operations ====================

  /// Load tất cả categories của tất cả groupType (0-5)
  /// Gọi hàm này khi khởi tạo màn hình quản lý category
  Future<void> loadAllCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categoryGroups = await _categoryService.getAllCategoriesByAllGroups();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _normalizeErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load categories theo một groupType cụ thể
  Future<void> loadCategoriesByGroupType(int groupType) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final categoryGroup = await _categoryService.getCategoriesByGroupType(
        groupType,
      );
      _categoryGroups[groupType] = categoryGroup;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _normalizeErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh dữ liệu (pull to refresh)
  Future<void> refreshCategories() async {
    await loadAllCategories();
  }

  /// Thêm category mới
  Future<bool> addCategory({
    required String name,
    required String icon,
    required String color,
    required String backgroundColor,
    required int groupType,
    double expenseLimit = 0,
    double expenseAlertThreshold = 0,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newCategory = await _categoryService.createCategory(
        name: name,
        icon: icon,
        color: color,
        backgroundColor: backgroundColor,
        groupType: groupType,
        expenseLimit: expenseLimit,
        expenseAlertThreshold: expenseAlertThreshold,
      );

      // Kiểm tra xem category có id hợp lệ không (tránh thêm category rác)
      if (newCategory.id.isEmpty) {
        _errorMessage = 'Failed to create category: Invalid response';
        return false;
      }

      // Cập nhật local state: thêm category vào group tương ứng
      _addCategoryToLocalState(newCategory, groupType);
      
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _normalizeErrorMessage(e);
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  /// Cập nhật category
  Future<bool> updateCategory({
    required String id,
    required String name,
    required String icon,
    required String color,
    required String backgroundColor,
    required int groupType,
    double expenseLimit = 0,
    double expenseAlertThreshold = 0,
    int? oldGroupType, // Nếu groupType thay đổi, cần biết group cũ để xóa
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedCategory = await _categoryService.updateCategory(
        id: id,
        name: name,
        icon: icon,
        color: color,
        backgroundColor: backgroundColor,
        groupType: groupType,
        expenseLimit: expenseLimit,
        expenseAlertThreshold: expenseAlertThreshold,
      );

      // Nếu API không trả về color/background, giữ lại màu cũ từ local state
      CategoryModel categoryToUpdate = updatedCategory;
      final existingCategory = findCategoryById(id);
      if (existingCategory != null && updatedCategory.color.isEmpty) {
        categoryToUpdate = updatedCategory.copyWith(
          color: existingCategory.color,
          backgroundColor: existingCategory.backgroundColor,
        );
      }

      // Cập nhật local state
      _updateCategoryInLocalState(categoryToUpdate, groupType, oldGroupType);
      
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _normalizeErrorMessage(e);
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  /// Xóa một category
  Future<bool> deleteCategory(String id, int groupType) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _categoryService.deleteCategory(id);
      
      if (success) {
        // Cập nhật local state: xóa category khỏi group
        _removeCategoryFromLocalState(id, groupType);
      }
      
      _errorMessage = null;
      return success;
    } catch (e) {
      _errorMessage = _normalizeErrorMessage(e);
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  /// Xóa nhiều categories (bulk delete)
  Future<bool> deleteCategories(List<String> ids, int groupType) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _categoryService.deleteCategories(ids);
      
      if (success) {
        // Cập nhật local state: xóa các categories khỏi group
        for (var id in ids) {
          _removeCategoryFromLocalState(id, groupType);
        }
      }
      
      _errorMessage = null;
      return success;
    } catch (e) {
      _errorMessage = _normalizeErrorMessage(e);
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  /// Xóa nhiều categories từ nhiều groups khác nhau
  Future<bool> deleteCategoriesFromMultipleGroups(Map<int, List<String>> groupedIds) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Lấy tất cả ids
      final allIds = groupedIds.values.expand((ids) => ids).toList();
      final success = await _categoryService.deleteCategories(allIds);
      
      if (success) {
        // Cập nhật local state cho từng group
        groupedIds.forEach((groupType, ids) {
          for (var id in ids) {
            _removeCategoryFromLocalState(id, groupType);
          }
        });
      }
      
      _errorMessage = null;
      return success;
    } catch (e) {
      _errorMessage = _normalizeErrorMessage(e);
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  // ==================== Helper Methods cho Local State ====================

  /// Thêm category vào local state
  void _addCategoryToLocalState(CategoryModel category, int groupType) {
    if (_categoryGroups.containsKey(groupType)) {
      final currentGroup = _categoryGroups[groupType]!;
      final updatedCategories = [...currentGroup.categories, category];
      _categoryGroups[groupType] = currentGroup.copyWith(categories: updatedCategories);
    } else {
      // Nếu group chưa tồn tại, tạo mới
      _categoryGroups[groupType] = CategoryGroup(
        name: GroupType.fromValue(groupType).displayName,
        type: groupType,
        categories: [category],
      );
    }
  }

  /// Cập nhật category trong local state
  void _updateCategoryInLocalState(
    CategoryModel updatedCategory,
    int newGroupType,
    int? oldGroupType,
  ) {
    // Nếu groupType thay đổi, xóa khỏi group cũ
    if (oldGroupType != null && oldGroupType != newGroupType) {
      _removeCategoryFromLocalState(updatedCategory.id, oldGroupType);
    }

    if (_categoryGroups.containsKey(newGroupType)) {
      final currentGroup = _categoryGroups[newGroupType]!;
      final categoryIndex = currentGroup.categories.indexWhere(
        (c) => c.id == updatedCategory.id,
      );

      if (categoryIndex != -1) {
        // Category đã tồn tại trong group -> update
        final updatedCategories = [...currentGroup.categories];
        updatedCategories[categoryIndex] = updatedCategory;
        _categoryGroups[newGroupType] = currentGroup.copyWith(categories: updatedCategories);
      } else {
        // Category chưa tồn tại trong group (do đổi groupType) -> thêm mới
        final updatedCategories = [...currentGroup.categories, updatedCategory];
        _categoryGroups[newGroupType] = currentGroup.copyWith(
          categories: updatedCategories,
        );
      }
    } else {
      // Group chưa tồn tại -> tạo mới
      _categoryGroups[newGroupType] = CategoryGroup(
        name: GroupType.fromValue(newGroupType).displayName,
        type: newGroupType,
        categories: [updatedCategory],
      );
    }
  }

  /// Xóa category khỏi local state
  void _removeCategoryFromLocalState(String categoryId, int groupType) {
    if (_categoryGroups.containsKey(groupType)) {
      final currentGroup = _categoryGroups[groupType]!;
      final updatedCategories = currentGroup.categories
          .where((c) => c.id != categoryId)
          .toList();
      _categoryGroups[groupType] = currentGroup.copyWith(
        categories: updatedCategories,
      );
    }
  }

  /// Tìm category theo ID trong tất cả groups
  CategoryModel? findCategoryById(String id) {
    for (var group in _categoryGroups.values) {
      final category = group.categories.where((c) => c.id == id).firstOrNull;
      if (category != null) return category;
    }
    return null;
  }

  /// Tìm groupType của một category theo ID
  int? findGroupTypeOfCategory(String categoryId) {
    for (var entry in _categoryGroups.entries) {
      if (entry.value.categories.any((c) => c.id == categoryId)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _categoryGroups = {};
    _isLoading = false;
    _isActionLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}