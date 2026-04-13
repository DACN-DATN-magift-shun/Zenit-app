import 'package:flutter/material.dart';
import 'package:zenit/features/setting_childs/category_manage/utils/category_color_palette.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';
import 'package:zenit/features/setting_childs/money_source_manage/services/money_source_service.dart';

class MoneySourceProvider extends ChangeNotifier {
  MoneySourceProvider({MoneySourceService? moneySourceService})
    : _moneySourceService = moneySourceService ?? MoneySourceService();

  final MoneySourceService _moneySourceService;

  List<MoneySourceModel> _moneySources = [];
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;

  List<MoneySourceModel> get moneySources => _moneySources;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _moneySources.isNotEmpty;

  Future<void> loadAllMoneySources() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _moneySources = await _moneySourceService.getAllMoneySources();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshMoneySources() async {
    await loadAllMoneySources();
  }

  Future<bool> addMoneySource({
    required String name,
    required String icon,
    int amount = 0,
    String note = '',
    bool isIncludeInTotalBalance = true,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final colorPair = CategoryColorPalette.getRandomColorPair();
      await _moneySourceService.createMoneySource(
        name: name,
        icon: icon,
        backgroundColorHex: colorPair.backgroundColorHex,
        amount: amount,
        note: note,
        isIncludeInTotalBalance: isIncludeInTotalBalance,
      );

      // Re-load from server because create response payload can vary by backend.
      _moneySources = await _moneySourceService.getAllMoneySources();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMoneySource({
    required String id,
    required String name,
    required String icon,
    int amount = 0,
    String note = '',
    bool isIncludeInTotalBalance = true,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final current = _moneySources.firstWhere(
        (item) => item.id == id,
        orElse: () => MoneySourceModel(
          id: id,
          name: name,
          iconName: icon,
          backgroundColorHex: '#E3F2FD',
        ),
      );

      final updatedMoneySource = await _moneySourceService.updateMoneySource(
        id: id,
        name: name,
        icon: icon,
        backgroundColorHex: current.backgroundColorHex,
        amount: amount,
        note: note,
        isIncludeInTotalBalance: isIncludeInTotalBalance,
      );

      final index = _moneySources.indexWhere((item) => item.id == id);
      if (index != -1) {
        _moneySources[index] = updatedMoneySource;
      }

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMoneySource(String id) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _moneySourceService.deleteMoneySource(id);
      if (success) {
        _moneySources.removeWhere((item) => item.id == id);
      }
      _errorMessage = null;
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }
}
