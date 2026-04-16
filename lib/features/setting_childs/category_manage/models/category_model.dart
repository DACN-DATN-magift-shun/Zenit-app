/// Helper để convert Map an toàn
Map<String, dynamic> _safeMap(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data;
  } else if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return {};
}

/// Model đại diện cho một Category từ API
class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String color;
  final String backgroundColor;
  final double expenseLimit;
  final double expenseAlertThreshold;
  final String groupType;
  final String? accountId;
  final String? createdById;
  final DateTime? createdAt;
  final bool isDeleted;
  final String? deletedById;
  final DateTime? deletedAt;
  final String? modifiedById;
  final DateTime? lastModifiedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.color = '#FFFFFF',
    this.backgroundColor = '#000000',
    this.expenseLimit = 0,
    this.expenseAlertThreshold = 0,
    required this.groupType,
    this.accountId,
    this.createdById,
    this.createdAt,
    this.isDeleted = false,
    this.deletedById,
    this.deletedAt,
    this.modifiedById,
    this.lastModifiedAt,
  });

  /// Parse từ JSON response
  factory CategoryModel.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      color: json['color']?.toString() ?? '#FFFFFF',
      backgroundColor: json['backgroundColor']?.toString() ?? '#000000',
      expenseLimit: _parseDouble(json['expenseLimit']),
      expenseAlertThreshold: _parseDouble(json['expenseAlertThreshold']),
      groupType: json['groupType']?.toString() ?? '0',
      accountId: json['accountId']?.toString(),
      createdById: json['createdById']?.toString(),
      createdAt: _parseDateTime(json['createdAt']),
      isDeleted: json['isDeleted'] == true,
      deletedById: json['deletedById']?.toString(),
      deletedAt: _parseDateTime(json['deletedAt']),
      modifiedById: json['modifiedById']?.toString(),
      lastModifiedAt: _parseDateTime(json['lastModifiedAt']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Convert sang JSON để gửi lên API (POST/PATCH)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
      'backgroundColor': backgroundColor,
      'expenseLimit': expenseLimit,
      'expenseAlertThreshold': expenseAlertThreshold,
      'groupType': groupType,
    };
  }

  /// Convert sang JSON với id (dùng cho PATCH)
  Map<String, dynamic> toJsonWithId() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'backgroundColor': backgroundColor,
      'expenseLimit': expenseLimit,
      'expenseAlertThreshold': expenseAlertThreshold,
      'groupType': groupType,
    };
  }

  /// Copy với các giá trị mới
  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    String? backgroundColor,
    double? expenseLimit,
    double? expenseAlertThreshold,
    String? groupType,
    String? accountId,
    String? createdById,
    DateTime? createdAt,
    bool? isDeleted,
    String? deletedById,
    DateTime? deletedAt,
    String? modifiedById,
    DateTime? lastModifiedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      expenseLimit: expenseLimit ?? this.expenseLimit,
      expenseAlertThreshold:
          expenseAlertThreshold ?? this.expenseAlertThreshold,
      groupType: groupType ?? this.groupType,
      accountId: accountId ?? this.accountId,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedById: deletedById ?? this.deletedById,
      deletedAt: deletedAt ?? this.deletedAt,
      modifiedById: modifiedById ?? this.modifiedById,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, icon: $icon, color: $color, backgroundColor: $backgroundColor, groupType: $groupType)';
  }
}

/// Model đại diện cho một nhóm Category (GroupType)
class CategoryGroup {
  final String name;
  final int type;
  final List<CategoryModel> categories;

  CategoryGroup({
    required this.name,
    required this.type,
    required this.categories,
  });

  /// Parse từ JSON response của API get categories by groupType
  factory CategoryGroup.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);

    // Parse categories list safely
    List<CategoryModel> categoryList = [];
    final categoriesData = json['categories'];

    if (categoriesData != null && categoriesData is List) {
      categoryList = categoriesData
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    }

    // Parse type safely - could be int or String
    int typeValue = 0;
    final typeData = json['type'];
    if (typeData is int) {
      typeValue = typeData;
    } else if (typeData is String) {
      typeValue = int.tryParse(typeData) ?? 0;
    }

    return CategoryGroup(
      name: json['name']?.toString() ?? '',
      type: typeValue,
      categories: categoryList,
    );
  }

  /// Copy với categories mới
  CategoryGroup copyWith({
    String? name,
    int? type,
    List<CategoryModel>? categories,
  }) {
    return CategoryGroup(
      name: name ?? this.name,
      type: type ?? this.type,
      categories: categories ?? this.categories,
    );
  }

  @override
  String toString() {
    return 'CategoryGroup(name: $name, type: $type, categories: ${categories.length})';
  }
}

/// Enum cho các loại GroupType (0-5)
enum GroupType {
  necessary(0, 'Necessary'),
  assets(1, 'Assets'),
  selfDevelopment(2, 'Self Development'),
  entertainment(3, 'Entertainment'),
  giving(4, 'Giving'),
  income(5, 'Income');

  final int value;
  final String displayName;

  const GroupType(this.value, this.displayName);

  /// Lấy GroupType từ int value
  static GroupType fromValue(int value) {
    return GroupType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GroupType.necessary,
    );
  }
}
