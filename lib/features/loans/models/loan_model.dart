class LoanModel {
  const LoanModel({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.date,
    required this.dueDate,
      this.note = '',
      this.status = 0,
  });

  final String id;
  final String name;
  final int type;
  final int amount;
  final DateTime date;
  final DateTime dueDate;
  final String note;
  final int status;

  bool get isLoan => type == 0;
  bool get isDebt => type == 1;

  LoanModel copyWith({
    String? id,
    String? name,
    int? type,
    int? amount,
    DateTime? date,
    DateTime? dueDate,
    String? note,
    int? status,
  }) {
    return LoanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'type': type,
      'status': status,
      'amount': amount,
      'date': date.toUtc().toIso8601String(),
      'dueDate': dueDate.toUtc().toIso8601String(),
      'note': note,
    };
  }

  Map<String, dynamic> toPatchJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'amount': amount,
      'date': date.toUtc().toIso8601String(),
      'dueDate': dueDate.toUtc().toIso8601String(),
      'note': note,
    };
  }

  factory LoanModel.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);

    return LoanModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: _parseInt(json['type']),
      status: _parseInt(json['status']),
      amount: _parseInt(json['amount']),
      date: _parseDate(json['date']) ?? DateTime.now(),
      dueDate:
          _parseDate(json['dueDate']) ??
          _parseDate(json['date']) ??
          DateTime.now(),
      note: json['note']?.toString() ?? '',
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
