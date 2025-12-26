/// Helper để convert Map an toàn
Map<String, dynamic> _safeMap(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data;
  } else if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return {};
}

/// Helper để parse int an toàn
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Helper để parse double an toàn
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

/// Model cho category trong statistics
class StatisticsCategoryModel {
  final String id;
  final String name;
  final String icon;
  final String color;
  final String backgroundColor;
  final int totalAmount;
  final double percentage;

  StatisticsCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.totalAmount,
    required this.percentage,
  });

  factory StatisticsCategoryModel.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);
    return StatisticsCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      color: json['color']?.toString() ?? '#FFFFFF',
      backgroundColor: json['backgroundColor']?.toString() ?? '#000000',
      totalAmount: _parseInt(json['totalAmount']),
      percentage: _parseDouble(json['percentage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'backgroundColor': backgroundColor,
      'totalAmount': totalAmount,
      'percentage': percentage,
    };
  }
}

/// Model cho từng group trong statistics (Thu nhập hoặc Chi tiêu)
class StatisticsGroupModel {
  final int totalAmount;
  final double percentage;
  final double percentageChange;
  final int groupType; // 0: Chi tiêu, 1: Thu nhập
  final List<StatisticsCategoryModel> categories;

  StatisticsGroupModel({
    required this.totalAmount,
    required this.percentage,
    required this.percentageChange,
    required this.groupType,
    required this.categories,
  });

  factory StatisticsGroupModel.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);
    return StatisticsGroupModel(
      totalAmount: _parseInt(json['totalAmount']),
      percentage: _parseDouble(json['percentage']),
      percentageChange: _parseDouble(json['percentageChange']),
      groupType: _parseInt(json['groupType']),
      categories: (json['categories'] as List<dynamic>?)
              ?.map((item) => StatisticsCategoryModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAmount': totalAmount,
      'percentage': percentage,
      'percentageChange': percentageChange,
      'groupType': groupType,
      'categories': categories.map((c) => c.toJson()).toList(),
    };
  }

  /// Lấy tên hiển thị của group
  String get groupName {
    switch (groupType) {
      case 0:
        return 'Neccessary'; // Sinh hoạt thiết yếu
      case 1:
        return 'Savings'; // Tiết kiệm
      case 2:
        return 'SelfDevelopment'; // Phát triển bản thân
      case 3:
        return 'Entertainment'; // Giải trí
      case 4:
        return 'Other'; // Khác
      default:
        return 'Unknown';
    }
  }
}

/// Model cho response của Statistics API
class StatisticsResponseModel {
  final List<StatisticsGroupModel> items;

  StatisticsResponseModel({
    required this.items,
  });

  factory StatisticsResponseModel.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);
    return StatisticsResponseModel(
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => StatisticsGroupModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  /// Lấy group Chi tiêu (groupType = 0)
  StatisticsGroupModel? get expenseGroup {
    try {
      return items.firstWhere((item) => item.groupType == 0);
    } catch (e) {
      return null;
    }
  }

  /// Lấy group Thu nhập (groupType = 1)
  StatisticsGroupModel? get incomeGroup {
    try {
      return items.firstWhere((item) => item.groupType == 1);
    } catch (e) {
      return null;
    }
  }

  /// Tổng số tiền của tất cả các group
  int get totalAmount {
    return items.fold(0, (sum, item) => sum + item.totalAmount);
  }
}
