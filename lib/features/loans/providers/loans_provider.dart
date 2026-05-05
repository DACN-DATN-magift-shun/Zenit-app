import 'package:flutter/material.dart';
import 'package:zenit/features/loans/models/loan_model.dart';
import 'package:zenit/features/loans/services/loans_service.dart';

class LoansProvider extends ChangeNotifier {
  LoansProvider({LoansService? loansService})
    : _loansService = loansService ?? LoansService();

  final LoansService _loansService;

  List<LoanModel> _loans = [];
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  int? _selectedTypeFilter;
  String _searchKeyword = '';

  List<LoanModel> get loans => _loans;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedTypeFilter => _selectedTypeFilter;
  String get searchKeyword => _searchKeyword;
  bool get hasData => _loans.isNotEmpty;

  int get totalLoanAmount {
    return _loans
        .where((item) => item.type == 0)
        .fold(0, (sum, item) => sum + item.amount);
  }

  int get totalDebtAmount {
    return _loans
        .where((item) => item.type == 1)
        .fold(0, (sum, item) => sum + item.amount);
  }

  int get netBalance => totalLoanAmount - totalDebtAmount;

  Future<void> loadLoans({
    int? type,
    String? search,
    int pageSize = 100,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    _selectedTypeFilter = type;
    if (search != null) {
      _searchKeyword = search;
    }

    notifyListeners();

    try {
      _loans = await _loansService.getLoans(
        type: _selectedTypeFilter,
        search: _searchKeyword,
        pageSize: pageSize,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshLoans() async {
    await loadLoans(type: _selectedTypeFilter, search: _searchKeyword);
  }

  Future<void> setTypeFilter(int? type) async {
    _selectedTypeFilter = type;
    await loadLoans(type: type, search: _searchKeyword);
  }

  Future<void> setSearchKeyword(String keyword) async {
    _searchKeyword = keyword.trim();
    await loadLoans(type: _selectedTypeFilter, search: _searchKeyword);
  }

  Future<bool> addLoan({
    required String name,
    required int type,
    required int amount,
    required DateTime date,
    required DateTime dueDate,
    String note = '',
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loansService.createLoan(
        name: name,
        type: type,
        amount: amount,
        date: date,
        dueDate: dueDate,
        note: note,
      );

      await refreshLoans();
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

  Future<bool> updateLoan({
    required String id,
    required String name,
    required int type,
    required int amount,
    required DateTime date,
    required DateTime dueDate,
    required String note,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loansService.updateLoan(
        id: id,
        name: name,
        type: type,
        amount: amount,
        date: date,
        dueDate: dueDate,
        note: note,
      );

      await refreshLoans();
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

  Future<bool> deleteLoan(String id) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _loansService.deleteLoan(id);
      if (success) {
        _loans.removeWhere((item) => item.id == id);
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
