/// Enum to identify each action type in the HomeActionGrid
enum ActionType {
  transaction,
  // quickImport,
  loans,
  transfer,
  moneySourceManage,
  goals,
  moreActions,
}

/// Extension to provide additional properties for ActionType
extension ActionTypeExtension on ActionType {
  String get label {
    switch (this) {
      case ActionType.transaction:
        return 'Transaction';
      // case ActionType.quickImport:
      //   return 'Quick import';
      case ActionType.loans:
        return 'Loans';
      case ActionType.transfer:
        return 'Transfer';
      case ActionType.moneySourceManage:
        return 'Money source management';
      case ActionType.goals:
        return 'Goals';
      case ActionType.moreActions:
        return 'More actions';
    }
  }
}
