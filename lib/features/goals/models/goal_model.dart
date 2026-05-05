import 'dart:math' as math;

enum GoalStatus {
  ongoing(0),
  completed(1),
  paused(2);

  const GoalStatus(this.value);

  final int value;

  static GoalStatus fromInt(dynamic value) {
    final parsed = _parseInt(value);
    return GoalStatus.values.firstWhere(
      (status) => status.value == parsed,
      orElse: () => GoalStatus.ongoing,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class GoalModel {
  const GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.backgroundColor,
    required this.icon,
    required this.createdAt,
    required this.dueDate,
    this.note = '',
    this.status = GoalStatus.ongoing,
  });

  final String id;
  final String name;
  final int targetAmount;
  final int currentAmount;
  final String backgroundColor;
  final String icon;
  final DateTime createdAt;
  final DateTime dueDate;
  final String note;
  final GoalStatus status;

  double get progress {
    if (targetAmount <= 0) {
      return 0;
    }

    return math.max(0, math.min(currentAmount / targetAmount, 1)).toDouble();
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'backgroundColor': backgroundColor,
      'icon': icon,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'dueDate': dueDate.toUtc().toIso8601String(),
      'note': note,
      'status': status.value,
    };
  }

  GoalModel copyWith({
    String? id,
    String? name,
    int? targetAmount,
    int? currentAmount,
    String? backgroundColor,
    String? icon,
    DateTime? createdAt,
    DateTime? dueDate,
    String? note,
    GoalStatus? status,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }

  factory GoalModel.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);
    final dueDate = _parseDate(json['dueDate']) ??
        _parseDate(json['deadline']) ??
        _parseDate(json['createdAt']) ??
        DateTime.now();
    final createdAt =
        _parseDate(json['createdAt']) ??
        _parseDate(json['date']) ??
        DateTime.now();

    return GoalModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      targetAmount: _parseInt(json['targetAmount']),
      currentAmount: _parseInt(json['currentAmount']),
      backgroundColor: json['backgroundColor']?.toString() ?? '#D2E4FF',
      icon: json['icon']?.toString() ?? 'flag',
      createdAt: createdAt,
      dueDate: dueDate,
      note: json['note']?.toString() ?? '',
      status: GoalStatus.fromInt(json['status']),
    );
  }

  static Map<String, dynamic> _safeMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {};
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
