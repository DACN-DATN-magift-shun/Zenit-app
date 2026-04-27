import 'package:zenit/features/loans/models/loan_model.dart';

final loansProviderMockLoans = <LoanModel>[
  LoanModel(
    id: 'l-loan',
    name: 'Lend to A',
    type: 0,
    amount: 300,
    date: DateTime.parse('2026-04-01T00:00:00Z'),
    dueDate: DateTime.parse('2026-05-01T00:00:00Z'),
  ),
  LoanModel(
    id: 'l-debt',
    name: 'Borrow from B',
    type: 1,
    amount: 100,
    date: DateTime.parse('2026-04-02T00:00:00Z'),
    dueDate: DateTime.parse('2026-06-01T00:00:00Z'),
  ),
];

final loansProviderUpdatedList = <LoanModel>[
  ...loansProviderMockLoans,
  LoanModel(
    id: 'l-new',
    name: 'Borrow from C',
    type: 1,
    amount: 200,
    date: DateTime.parse('2026-04-03T00:00:00Z'),
    dueDate: DateTime.parse('2026-06-15T00:00:00Z'),
  ),
];
