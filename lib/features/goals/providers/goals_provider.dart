import 'package:flutter/material.dart';
import 'package:zenit/features/goals/models/goal_model.dart';
import 'package:zenit/features/goals/services/goals_service.dart';

class GoalsProvider extends ChangeNotifier {
  GoalsProvider({GoalsService? goalsService})
    : _goalsService = goalsService ?? GoalsService();

  final GoalsService _goalsService;

  List<GoalModel> _allGoals = [];
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  GoalStatus? _selectedStatusFilter;
  String _searchKeyword = '';

  List<GoalModel> get goals {
    return _allGoals.where((goal) {
      if (_selectedStatusFilter == null) {
        return true;
      }
      return goal.status == _selectedStatusFilter;
    }).toList();
  }

  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  GoalStatus? get selectedStatusFilter => _selectedStatusFilter;
  String get searchKeyword => _searchKeyword;
  bool get hasData => goals.isNotEmpty;

  List<GoalModel> get _ongoingGoalsForProgress {
    return _allGoals
        .where((goal) => goal.status == GoalStatus.ongoing)
        .toList();
  }

  int get totalTargetAmount {
    return _ongoingGoalsForProgress.fold(0, (sum, item) => sum + item.targetAmount);
  }

  int get totalCurrentAmount {
    return _ongoingGoalsForProgress.fold(0, (sum, item) => sum + item.currentAmount);
  }

  double get amountProgress {
    final target = totalTargetAmount;
    if (target <= 0) {
      return 0;
    }

    final ratio = totalCurrentAmount / target;
    if (ratio < 0) {
      return 0;
    }
    if (ratio > 1) {
      return 1;
    }
    return ratio;
  }

  int get completedGoalsCount {
    return goals.where((item) => item.status == GoalStatus.completed).length;
  }

  double get completionRate {
    if (goals.isEmpty) {
      return 0;
    }
    return completedGoalsCount / goals.length;
  }

  Future<void> loadGoals({String? search, int pageSize = 100}) async {
    _isLoading = true;
    _errorMessage = null;

    if (search != null) {
      _searchKeyword = search;
    }

    notifyListeners();

    try {
      _allGoals = await _goalsService.getGoals(
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

  Future<void> refreshGoals() async {
    await loadGoals(search: _searchKeyword);
  }

  Future<void> setStatusFilter(GoalStatus? status) async {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  Future<void> setSearchKeyword(String keyword) async {
    _searchKeyword = keyword.trim();
    await loadGoals(search: _searchKeyword);
  }

  Future<bool> addGoal({
    required String name,
    required int targetAmount,
    required int currentAmount,
    required String backgroundColor,
    required String icon,
    required DateTime dueDate,
    required String note,
    required GoalStatus status,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _goalsService.createGoal(
        name: name,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        backgroundColor: backgroundColor,
        icon: icon,
        dueDate: dueDate,
        note: note,
        status: status,
      );

      await refreshGoals();
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

  Future<bool> updateGoal({
    required String id,
    required String name,
    required int targetAmount,
    required int currentAmount,
    required String backgroundColor,
    required String icon,
    required DateTime dueDate,
    required String note,
    required GoalStatus status,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _goalsService.updateGoal(
        id: id,
        name: name,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        backgroundColor: backgroundColor,
        icon: icon,
        dueDate: dueDate,
        note: note,
        status: status,
      );

      await refreshGoals();
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

  Future<bool> deleteGoal(String id) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _goalsService.deleteGoal(id);
      if (success) {
        _allGoals.removeWhere((item) => item.id == id);
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
