import 'package:zenit/features/photos/models/photo_model.dart';

/// Helper để convert Map an toàn
Map<String, dynamic> _safeMap(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data;
  } else if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return {};
}

Map<String, dynamic> _unwrapTransactionPayload(dynamic rawJson) {
  final json = _safeMap(rawJson);
  final nestedData = _safeMap(json['data']);
  if (nestedData.isNotEmpty) {
    return nestedData;
  }

  final nestedResult = _safeMap(json['result']);
  if (nestedResult.isNotEmpty) {
    return nestedResult;
  }

  final nestedTransaction = _safeMap(json['transaction']);
  if (nestedTransaction.isNotEmpty) {
    return nestedTransaction;
  }

  final nestedItem = _safeMap(json['item']);
  if (nestedItem.isNotEmpty) {
    return nestedItem;
  }

  final nestedRecord = _safeMap(json['record']);
  if (nestedRecord.isNotEmpty) {
    return nestedRecord;
  }

  final nestedEntity = _safeMap(json['entity']);
  if (nestedEntity.isNotEmpty) {
    return nestedEntity;
  }

  return json;
}

String? _findStringByKeys(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }

  for (final value in json.values) {
    if (value is Map) {
      final nested = _findStringByKeys(Map<String, dynamic>.from(value), keys);
      if (nested != null && nested.isNotEmpty) {
        return nested;
      }
    }
  }

  return null;
}

/// Model cho thông tin Category trong Transaction
class TransactionCategoryModel {
  final String id;
  final String name;
  final String icon;
  final String color;
  final String backgroundColor;
  final int groupType;

  TransactionCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.groupType,
  });

  factory TransactionCategoryModel.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);
    return TransactionCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      color: json['color']?.toString() ?? '#FFFFFF',
      backgroundColor: json['backgroundColor']?.toString() ?? '#000000',
      groupType: _parseInt(json['groupType']),
    );
  }
}

/// Model đại diện cho một Transaction từ API
class TransactionModel {
  final String? id;
  final String title;
  final String? note;
  final int amount;
  final DateTime transactionDate;
  final String categoryId;
  final String walletId;
  final TransactionCategoryModel? category;
  final String? accountId;
  final String? createdById;
  final DateTime? createdAt;
  final bool isDeleted;
  final String? deletedById;
  final DateTime? deletedAt;
  final String? modifiedById;
  final DateTime? lastModifiedAt;
  final List<PhotoModel> photos;

  TransactionModel({
    this.id,
    required this.title,
    this.note,
    required this.amount,
    required this.transactionDate,
    required this.categoryId,
    required this.walletId,
    this.category,
    this.accountId,
    this.createdById,
    this.createdAt,
    this.isDeleted = false,
    this.deletedById,
    this.deletedAt,
    this.modifiedById,
    this.lastModifiedAt,
    this.photos = const [],
  });

  /// Parse từ JSON response
  factory TransactionModel.fromJson(dynamic rawJson) {
    final json = _unwrapTransactionPayload(rawJson);
    return TransactionModel(
      id: _findStringByKeys(json, const [
        'id',
        'transactionId',
        'transactionID',
      ]),
      title: json['title']?.toString() ?? '',
      note: json['note']?.toString(),
      amount: _parseInt(json['amount']),
      transactionDate:
          _parseDateTime(json['transactionDate']) ?? DateTime.now(),
      categoryId: json['categoryId']?.toString() ?? '',
      walletId:
          json['walletId']?.toString() ??
          json['walletID']?.toString() ??
          json['wallet_id']?.toString() ??
          _safeMap(json['wallet'])['id']?.toString() ??
          '',
      category: json['category'] != null
          ? TransactionCategoryModel.fromJson(json['category'])
          : null,
      accountId: json['accountId']?.toString(),
      createdById: json['createdById']?.toString(),
      createdAt: _parseDateTime(json['createdAt']),
      isDeleted: json['isDeleted'] == true,
      deletedById: json['deletedById']?.toString(),
      deletedAt: _parseDateTime(json['deletedAt']),
      modifiedById: json['modifiedById']?.toString(),
      lastModifiedAt: _parseDateTime(json['lastModifiedAt']),
      photos: _parsePhotos(json['photos']),
    );
  }

  static List<PhotoModel> _parsePhotos(dynamic value) {
    if (value is List) {
      return value.map((item) => PhotoModel.fromJson(item)).toList();
    }

    if (value is Map) {
      return [PhotoModel.fromJson(value)];
    }

    return [];
  }

  String? get firstPhotoUrl {
    for (final photo in photos) {
      if (photo.url != null && photo.url!.isNotEmpty) {
        return photo.url;
      }
    }
    return null;
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
      'walletId': walletId,
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
      'walletId': walletId,
    };
  }

  Map<String, dynamic> toJsonForDetail() {
    return {
      'id': id,
      'title': title,
      'note': note ?? '',
      'amount': amount,
      'transactionDate': transactionDate.toUtc().toIso8601String(),
      'categoryId': categoryId,
      'walletId': walletId,
      if (category != null)
        'category': {
          'id': category!.id,
          'name': category!.name,
          'icon': category!.icon,
          'color': category!.color,
          'backgroundColor': category!.backgroundColor,
          'groupType': category!.groupType,
        },
      if (accountId != null) 'accountId': accountId,
      if (createdById != null) 'createdById': createdById,
      if (createdAt != null) 'createdAt': createdAt!.toUtc().toIso8601String(),
      'isDeleted': isDeleted,
      if (deletedById != null) 'deletedById': deletedById,
      if (deletedAt != null) 'deletedAt': deletedAt!.toUtc().toIso8601String(),
      if (modifiedById != null) 'modifiedById': modifiedById,
      if (lastModifiedAt != null)
        'lastModifiedAt': lastModifiedAt!.toUtc().toIso8601String(),
      if (photos.isNotEmpty)
        'photos': photos
            .map(
              (photo) => {
                'id': photo.id,
                'name': photo.name,
                'filePath': photo.url,
                'url': photo.url,
              },
            )
            .toList(),
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
    String? walletId,
    TransactionCategoryModel? category,
    String? accountId,
    String? createdById,
    DateTime? createdAt,
    bool? isDeleted,
    String? deletedById,
    DateTime? deletedAt,
    String? modifiedById,
    DateTime? lastModifiedAt,
    List<PhotoModel>? photos,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      transactionDate: transactionDate ?? this.transactionDate,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      category: category ?? this.category,
      accountId: accountId ?? this.accountId,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedById: deletedById ?? this.deletedById,
      deletedAt: deletedAt ?? this.deletedAt,
      modifiedById: modifiedById ?? this.modifiedById,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      photos: photos ?? this.photos,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, title: $title, amount: $amount, transactionDate: $transactionDate, categoryId: $categoryId, walletId: $walletId)';
  }
}

/// Model cho metadata phân trang
class TransactionMetaModel {
  final int totalItems;
  final int pageCount;
  final int? page;
  final int pageSize;

  TransactionMetaModel({
    required this.totalItems,
    required this.pageCount,
    this.page,
    required this.pageSize,
  });

  factory TransactionMetaModel.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);
    return TransactionMetaModel(
      totalItems: _parseInt(json['totalItems']),
      pageCount: _parseInt(json['pageCount']),
      page: json['page'] != null ? _parseInt(json['page']) : null,
      pageSize: _parseInt(json['pageSize']),
    );
  }
}

/// Model cho response danh sách Transaction
class TransactionListResponse {
  final List<TransactionModel> items;
  final TransactionMetaModel meta;

  TransactionListResponse({required this.items, required this.meta});

  factory TransactionListResponse.fromJson(dynamic rawJson) {
    final json = _unwrapTransactionPayload(rawJson);
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return TransactionListResponse(
      items: itemsList.map((item) => TransactionModel.fromJson(item)).toList(),
      meta: TransactionMetaModel.fromJson(json['meta']),
    );
  }
}

/// Helper function để parse int
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
