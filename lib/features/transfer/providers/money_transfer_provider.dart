import 'package:flutter/material.dart';
import 'package:zenit/features/transfer/models/money_transfer_model.dart';
import 'package:zenit/features/transfer/services/money_transfer_service.dart';

class MoneyTransferProvider extends ChangeNotifier {
  MoneyTransferProvider({MoneyTransferService? moneyTransferService})
    : _moneyTransferService = moneyTransferService ?? MoneyTransferService();

  final MoneyTransferService _moneyTransferService;

  List<MoneyTransferModel> _transfers = [];
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  String _searchKeyword = '';

  List<MoneyTransferModel> get transfers => _transfers;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  String get searchKeyword => _searchKeyword;
  bool get hasData => _transfers.isNotEmpty;

  Future<void> loadTransfers({String? search, int pageSize = 100}) async {
    _isLoading = true;
    _errorMessage = null;

    if (search != null) {
      _searchKeyword = search.trim();
    }

    notifyListeners();

    try {
      final response = await _moneyTransferService.getMoneyTransfers(
        search: _searchKeyword,
        pageSize: pageSize,
      );

      _transfers = response.items;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTransfers() async {
    await loadTransfers(search: _searchKeyword);
  }

  Future<void> setSearchKeyword(String keyword) async {
    _searchKeyword = keyword.trim();
    await loadTransfers(search: _searchKeyword);
  }

  Future<bool> addTransfer({
    required String fromWalletId,
    required String toWalletId,
    required int amount,
    required DateTime transferDate,
    String note = '',
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _moneyTransferService.createMoneyTransfer(
        fromWalletId: fromWalletId,
        toWalletId: toWalletId,
        amount: amount,
        transferDate: transferDate,
        note: note,
      );

      await refreshTransfers();
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

  Future<bool> updateTransfer({
    required String id,
    required String fromWalletId,
    required String toWalletId,
    required int amount,
    required DateTime transferDate,
    required String note,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _moneyTransferService.updateMoneyTransfer(
        id: id,
        fromWalletId: fromWalletId,
        toWalletId: toWalletId,
        amount: amount,
        transferDate: transferDate,
        note: note,
      );

      await refreshTransfers();
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

  Future<bool> deleteTransfer(String id) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _moneyTransferService.deleteMoneyTransfer(id);
      if (success) {
        _transfers.removeWhere((item) => item.id == id);
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
