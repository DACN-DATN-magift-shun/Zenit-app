/// Helper để convert Map an toàn
Map<String, dynamic> _safeMap(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data;
  } else if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return {};
}

/// Model đại diện cho một Transaction từ API
class TransactionModel {
  final String? id;
  final String title;
  final String? note;
  final int amount;
  final DateTime transactionDate;
  final String categoryId;
  final String? accountId;
  final String? createdById;
  final DateTime? createdAt;
  final bool isDeleted;
  final String? deletedById;
  final DateTime? deletedAt;
  final String? modifiedById;
  final DateTime? lastModifiedAt;

  TransactionModel({
    this.id,
    required this.title,
    this.note,
    required this.amount,
    required this.transactionDate,
    required this.categoryId,
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
  factory TransactionModel.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);
    return TransactionModel(
      id: json['id']?.toString(),
      title: json['title']?.toString() ?? '',
      note: json['note']?.toString(),
      amount: _parseInt(json['amount']),
      transactionDate: _parseDateTime(json['transactionDate']) ?? DateTime.now(),
      categoryId: json['categoryId']?.toString() ?? '',
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

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
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

  /// Convert sang JSON để gửi lên API (POST)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'note': note ?? '',
      'amount': amount,
      'transactionDate': transactionDate.toUtc().toIso8601String(),
      'categoryId': categoryId,
    };
  }

  /// Convert sang JSON với id (dùng cho PATCH)
  Map<String, dynamic> toJsonWithId() {
    return {
      'id': id,
      'title': title,
      'note': note ?? '',
      'amount': amount,
      'transactionDate': transactionDate.toUtc().toIso8601String(),
      'categoryId': categoryId,
    };
  }

  /// Copy với các giá trị mới
  TransactionModel copyWith({
    String? id,
    String? title,
    String? note,
    int? amount,
    DateTime? transactionDate,
    String? categoryId,
    String? accountId,
    String? createdById,
    DateTime? createdAt,
    bool? isDeleted,
    String? deletedById,
    DateTime? deletedAt,
    String? modifiedById,
    DateTime? lastModifiedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      transactionDate: transactionDate ?? this.transactionDate,
      categoryId: categoryId ?? this.categoryId,
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
    return 'TransactionModel(id: $id, title: $title, amount: $amount, transactionDate: $transactionDate, categoryId: $categoryId)';
  }
}
