import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/features/loans/models/loan_model.dart';
import '../../../mocks/features/loans/loan_model_mock_data.dart';
import '../../../mocks/json_source_mock.dart';

void main() {
  group('LoanModel', () {
    test('fromJson parses values and flags loan type', () {
      final source = MockJsonSource();
      when(() => source.value).thenReturn(loanFromJsonMockData);

      final model = LoanModel.fromJson(source.value);

      expect(model.id, 'l1');
      expect(model.amount, 3000000);
      expect(model.isLoan, true);
      expect(model.isDebt, false);
    });

    test('toPatchJson includes id and utc datetime strings', () {
      final model = LoanModel(
        id: 'l9',
        name: 'Debt',
        type: 1,
        amount: 100,
        date: DateTime.parse('2026-04-01T00:00:00Z'),
        dueDate: DateTime.parse('2026-04-10T00:00:00Z'),
      );

      final json = model.toPatchJson();

      expect(json['id'], 'l9');
      expect(json['type'], 1);
      expect((json['date'] as String).contains('T'), true);
    });

    test('copyWith overrides provided fields', () {
      final model = LoanModel(
        id: 'l2',
        name: 'Loan',
        type: 0,
        amount: 50,
        date: DateTime.parse('2026-04-01T00:00:00Z'),
        dueDate: DateTime.parse('2026-04-02T00:00:00Z'),
      );

      final copied = model.copyWith(amount: 75, type: 1);

      expect(copied.amount, 75);
      expect(copied.type, 1);
      expect(copied.name, 'Loan');
    });
  });
}
