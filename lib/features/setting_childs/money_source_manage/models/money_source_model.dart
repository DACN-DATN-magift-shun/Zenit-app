import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class MoneySourceModel {
  final String id;
  final String name;
  final int amount;
  final String iconName;
  final String backgroundColorHex;
  final String note;
  final bool isIncludeInTotalBalance;

  const MoneySourceModel({
    required this.id,
    required this.name,
    this.amount = 0,
    required this.iconName,
    required this.backgroundColorHex,
    this.note = '',
    this.isIncludeInTotalBalance = true,
  });

  IconData get iconData => MoneySourceIconMapper.fromName(iconName);

  Color get backgroundColor =>
      _parseColor(backgroundColorHex) ?? Colors.blue.shade100;

  Color get iconColor => _getContrastColor(backgroundColor);

  MoneySourceModel copyWith({
    String? id,
    String? name,
    int? amount,
    String? iconName,
    String? backgroundColorHex,
    String? note,
    bool? isIncludeInTotalBalance,
  }) {
    return MoneySourceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      iconName: iconName ?? this.iconName,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      note: note ?? this.note,
      isIncludeInTotalBalance:
          isIncludeInTotalBalance ?? this.isIncludeInTotalBalance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'icon': iconName,
      'backgroundColor': backgroundColorHex,
      'note': note,
      'isIncludeInTotalBalance': isIncludeInTotalBalance,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'amount': amount,
      'icon': iconName,
      'backgroundColor': backgroundColorHex,
      'note': note,
      'isIncludeInTotalBalance': isIncludeInTotalBalance,
    };
  }

  factory MoneySourceModel.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);
    final resolvedId =
        json['id']?.toString() ??
        json['walletId']?.toString() ??
        json['walletID']?.toString() ??
        json['wallet_id']?.toString() ??
        '';

    return MoneySourceModel(
      id: resolvedId,
      name: json['name']?.toString() ?? '',
      amount: _parseInt(json['amount']),
      iconName: json['icon']?.toString() ?? 'account_balance_wallet_rounded',
      backgroundColorHex: json['backgroundColor']?.toString() ?? '#E3F2FD',
      note: json['note']?.toString() ?? '',
      isIncludeInTotalBalance: _parseBool(json['isIncludeInTotalBalance']),
    );
  }

  static Map<String, dynamic> _safeMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
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

  static bool _parseBool(dynamic value) {
    if (value == null) return true;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return true;
  }

  static Color? _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return null;
    try {
      var hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return null;
    }
  }

  static Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.55
        ? const Color(0xFF111111)
        : Colors.white;
  }
}

class MoneySourceIconOption {
  final IconData icon;
  final String name;

  const MoneySourceIconOption({required this.icon, required this.name});
}

class MoneySourceIconMapper {
  static const List<MoneySourceIconOption> availableOptions = [
    MoneySourceIconOption(
      icon: Symbols.shopping_cart_rounded,
      name: 'shopping_cart_rounded',
    ),
    MoneySourceIconOption(
      icon: Symbols.restaurant_rounded,
      name: 'restaurant_rounded',
    ),
    MoneySourceIconOption(
      icon: Symbols.account_balance_rounded,
      name: 'account_balance_rounded',
    ),
    MoneySourceIconOption(
      icon: Symbols.trending_up_rounded,
      name: 'trending_up_rounded',
    ),
    MoneySourceIconOption(icon: Symbols.school_rounded, name: 'school_rounded'),
    MoneySourceIconOption(
      icon: Symbols.menu_book_rounded,
      name: 'menu_book_rounded',
    ),
    MoneySourceIconOption(icon: Symbols.movie_rounded, name: 'movie_rounded'),
    MoneySourceIconOption(
      icon: Symbols.fitness_center_rounded,
      name: 'fitness_center_rounded',
    ),
    MoneySourceIconOption(
      icon: Symbols.attach_money_rounded,
      name: 'attach_money_rounded',
    ),
    MoneySourceIconOption(
      icon: Symbols.account_balance_wallet_rounded,
      name: 'account_balance_wallet_rounded',
    ),
    MoneySourceIconOption(
      icon: Symbols.credit_card_rounded,
      name: 'credit_card_rounded',
    ),
    MoneySourceIconOption(
      icon: Symbols.savings_rounded,
      name: 'savings_rounded',
    ),
  ];

  static IconData fromName(String iconName) {
    final matched = availableOptions.where((option) => option.name == iconName);
    if (matched.isNotEmpty) {
      return matched.first.icon;
    }
    return Symbols.account_balance_wallet_rounded;
  }
}
