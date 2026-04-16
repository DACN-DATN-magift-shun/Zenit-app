Map<String, dynamic> _safeMap(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data;
  }
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return {};
}

Map<String, dynamic> _unwrapPayload(dynamic rawJson) {
  final json = _safeMap(rawJson);

  final nestedData = _safeMap(json['data']);
  if (nestedData.isNotEmpty) {
    return nestedData;
  }

  final nestedResult = _safeMap(json['result']);
  if (nestedResult.isNotEmpty) {
    return nestedResult;
  }

  return json;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

class TransferWalletModel {
  const TransferWalletModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.backgroundColor,
    required this.icon,
    required this.note,
    required this.isIncludeInTotalBalance,
    required this.accountId,
  });

  final String id;
  final String name;
  final int amount;
  final String backgroundColor;
  final String icon;
  final String note;
  final bool isIncludeInTotalBalance;
  final String accountId;

  factory TransferWalletModel.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);

    return TransferWalletModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: _parseInt(json['amount']),
      backgroundColor: json['backgroundColor']?.toString() ?? '#E3F2FD',
      icon: json['icon']?.toString() ?? 'account_balance_wallet_rounded',
      note: json['note']?.toString() ?? '',
      isIncludeInTotalBalance: json['isIncludeInTotalBalance'] == true,
      accountId: json['accountId']?.toString() ?? '',
    );
  }
}

class MoneyTransferModel {
  const MoneyTransferModel({
    required this.id,
    required this.fromWalletId,
    required this.toWalletId,
    required this.amount,
    required this.transferDate,
    required this.note,
    this.fromWallet,
    this.toWallet,
  });

  final String id;
  final String fromWalletId;
  final String toWalletId;
  final int amount;
  final DateTime transferDate;
  final String note;
  final TransferWalletModel? fromWallet;
  final TransferWalletModel? toWallet;

  MoneyTransferModel copyWith({
    String? id,
    String? fromWalletId,
    String? toWalletId,
    int? amount,
    DateTime? transferDate,
    String? note,
    TransferWalletModel? fromWallet,
    TransferWalletModel? toWallet,
  }) {
    return MoneyTransferModel(
      id: id ?? this.id,
      fromWalletId: fromWalletId ?? this.fromWalletId,
      toWalletId: toWalletId ?? this.toWalletId,
      amount: amount ?? this.amount,
      transferDate: transferDate ?? this.transferDate,
      note: note ?? this.note,
      fromWallet: fromWallet ?? this.fromWallet,
      toWallet: toWallet ?? this.toWallet,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'fromWalletId': fromWalletId,
      'toWalletId': toWalletId,
      'amount': amount,
      'transferDate': transferDate.toUtc().toIso8601String(),
      'note': note,
    };
  }

  Map<String, dynamic> toPatchJson() {
    return {
      'id': id,
      'fromWalletId': fromWalletId,
      'toWalletId': toWalletId,
      'amount': amount,
      'transferDate': transferDate.toUtc().toIso8601String(),
      'note': note,
    };
  }

  factory MoneyTransferModel.fromJson(dynamic rawJson) {
    final json = _unwrapPayload(rawJson);

    final fromWalletJson = _safeMap(json['fromWallet']);
    final toWalletJson = _safeMap(json['toWallet']);

    return MoneyTransferModel(
      id: json['id']?.toString() ?? '',
      fromWalletId: json['fromWalletId']?.toString() ?? '',
      toWalletId: json['toWalletId']?.toString() ?? '',
      amount: _parseInt(json['amount']),
      transferDate: _parseDate(json['transferDate']) ?? DateTime.now(),
      note: json['note']?.toString() ?? '',
      fromWallet: fromWalletJson.isNotEmpty
          ? TransferWalletModel.fromJson(fromWalletJson)
          : null,
      toWallet: toWalletJson.isNotEmpty
          ? TransferWalletModel.fromJson(toWalletJson)
          : null,
    );
  }
}

class MoneyTransferMetaModel {
  const MoneyTransferMetaModel({
    required this.totalItems,
    required this.pageCount,
    required this.page,
    required this.pageSize,
  });

  final int totalItems;
  final int pageCount;
  final int? page;
  final int pageSize;

  factory MoneyTransferMetaModel.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);

    return MoneyTransferMetaModel(
      totalItems: _parseInt(json['totalItems']),
      pageCount: _parseInt(json['pageCount']),
      page: json['page'] == null ? null : _parseInt(json['page']),
      pageSize: _parseInt(json['pageSize']),
    );
  }
}

class MoneyTransferListResponse {
  const MoneyTransferListResponse({required this.items, required this.meta});

  final List<MoneyTransferModel> items;
  final MoneyTransferMetaModel meta;

  factory MoneyTransferListResponse.fromJson(dynamic rawJson) {
    final json = _unwrapPayload(rawJson);
    final itemsJson = json['items'];

    final items = (itemsJson is List)
        ? itemsJson.map((item) => MoneyTransferModel.fromJson(item)).toList()
        : <MoneyTransferModel>[];

    return MoneyTransferListResponse(
      items: items,
      meta: MoneyTransferMetaModel.fromJson(json['meta']),
    );
  }
}
