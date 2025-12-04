/// Enum to identify each action type in the HomeActionGrid
enum ActionType {
  expense,
  income,
  quickImport,
  goals,
  loans,
  moreActions,
}

/// Extension to provide additional properties for ActionType
extension ActionTypeExtension on ActionType {
  String get label {
    switch (this) {
      case ActionType.expense:
        return 'Expense';
      case ActionType.income:
        return 'Income';
      case ActionType.quickImport:
        return 'Quick import';
      case ActionType.goals:
        return 'Goals';
      case ActionType.loans:
        return 'Loans';
      case ActionType.moreActions:
        return 'More actions';
    }
  }
}
