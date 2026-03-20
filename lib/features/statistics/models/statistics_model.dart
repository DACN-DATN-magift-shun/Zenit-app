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
      name: json['name']?.toString() ?? json['categoryName']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      color: json['color']?.toString() ?? '#FFFFFF',
      backgroundColor: json['backgroundColor']?.toString() ?? '#000000',
      totalAmount: _parseInt(json['totalAmount'] ?? json['amount']),
      percentage: _parseDouble(json['percentage'] ?? json['percent']),
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
  final int groupType; // 0: Necessary, 1: Savings, 2: SelfDevelopment, 3: Entertainment, 4: Giving
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
    final categoryListRaw =
        (json['categories'] ?? json['categoryStatistics']) as List<dynamic>? ??
        [];

    return StatisticsGroupModel(
      totalAmount: _parseInt(json['totalAmount'] ?? json['amount']),
      percentage: _parseDouble(json['percentage']),
      percentageChange: _parseDouble(json['percentageChange']),
      groupType: _parseInt(json['groupType']),
      categories: categoryListRaw
          .map((item) => StatisticsCategoryModel.fromJson(item))
          .toList(),
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
        return 'Necessary';
      case 1:
        return 'Savings';
      case 2:
        return 'Self Development';
      case 3:
        return 'Entertainment';
      case 4:
        return 'Giving';
      default:
        return 'Group $groupType';
    }
  }
}

/// Model tóm tắt thu/chi toàn khoảng thời gian
class IncomeExpenseStatisticsModel {
  final int totalIncome;
  final int totalExpense;
  final double incomePercentageChange;
  final double expensePercentageChange;

  const IncomeExpenseStatisticsModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.incomePercentageChange,
    required this.expensePercentageChange,
  });

  factory IncomeExpenseStatisticsModel.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);
    return IncomeExpenseStatisticsModel(
      totalIncome: _parseInt(json['totalIncome']),
      totalExpense: _parseInt(json['totalExpense']),
      incomePercentageChange: _parseDouble(json['incomePercentageChange']),
      expensePercentageChange: _parseDouble(json['expensePercentageChange']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'incomePercentageChange': incomePercentageChange,
      'expensePercentageChange': expensePercentageChange,
    };
  }
}

/// Model cho response của Statistics API
class StatisticsResponseModel {
  final List<StatisticsGroupModel> items;
  final IncomeExpenseStatisticsModel incomeExpenseStatistics;

  StatisticsResponseModel({
    required this.items,
    required this.incomeExpenseStatistics,
  });

  factory StatisticsResponseModel.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);
    final groupsRaw = (json['items'] ?? json['groupStatistics']) as List<dynamic>? ?? [];

    return StatisticsResponseModel(
      items: groupsRaw
          .map((item) => StatisticsGroupModel.fromJson(item))
          .toList(),
      incomeExpenseStatistics: IncomeExpenseStatisticsModel.fromJson(
        json['incomeExpenseStatistics'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => i.toJson()).toList(),
      'incomeExpenseStatistics': incomeExpenseStatistics.toJson(),
    };
  }

  /// Lấy group Necessary (groupType = 0)
  StatisticsGroupModel? get necessaryGroup {
    try {
      return items.firstWhere((item) => item.groupType == 0);
    } catch (e) {
      return null;
    }
  }

  /// Lấy group Savings (groupType = 1)
  StatisticsGroupModel? get savingsGroup {
    try {
      return items.firstWhere((item) => item.groupType == 1);
    } catch (e) {
      return null;
    }
  }

  /// Lấy group Self Development (groupType = 2)
  StatisticsGroupModel? get selfDevelopmentGroup {
    try {
      return items.firstWhere((item) => item.groupType == 2);
    } catch (e) {
      return null;
    }
  }

  /// Lấy group Entertainment (groupType = 3)
  StatisticsGroupModel? get entertainmentGroup {
    try {
      return items.firstWhere((item) => item.groupType == 3);
    } catch (e) {
      return null;
    }
  }

  /// Lấy group Giving (groupType = 4)
  StatisticsGroupModel? get givingGroup {
    try {
      return items.firstWhere((item) => item.groupType == 4);
    } catch (e) {
      return null;
    }
  }

  @Deprecated('Use necessaryGroup instead. groupType 0 is Necessary, not Expense.')
  StatisticsGroupModel? get expenseGroup => necessaryGroup;

  @Deprecated('Use savingsGroup instead. groupType 1 is Savings, not Income.')
  StatisticsGroupModel? get incomeGroup => savingsGroup;

  /// Tổng số tiền của tất cả các group
  int get totalAmount {
    return items.fold(0, (sum, item) => sum + item.totalAmount);
  }
}
