import 'package:zenit/features/loans/models/loan_model.dart';

final loanWidgetLoan = LoanModel(
  id: 'l1',
  name: 'Borrow from A',
  type: 0,
  amount: 3000000,
  date: DateTime.utc(2026, 4, 1),
  dueDate: DateTime.utc(2026, 6, 1),
  note: 'monthly return',
);

final loanWidgetDebt = LoanModel(
  id: 'l2',
  name: 'Borrow from B',
  type: 1,
  amount: 1500000,
  date: DateTime.utc(2026, 4, 5),
  dueDate: DateTime.utc(2026, 7, 5),
  note: '',
);