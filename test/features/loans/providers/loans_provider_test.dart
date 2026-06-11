import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/features/loans/providers/loans_provider.dart';
import 'package:zenit/features/loans/services/loans_service.dart';

import '../../../mocks/features/loans/loans_provider_mock_data.dart';

class MockLoansService extends Mock implements LoansService {}

void main() {
  late MockLoansService loansService;
  late LoansProvider provider;

  setUp(() {
    loansService = MockLoansService();
    provider = LoansProvider(loansService: loansService);
  });

  group('LoansProvider', () {
    test('loadLoans success updates totals', () async {
      when(
        () => loansService.getLoans(type: null, search: null, pageSize: 100),
      ).thenAnswer((_) async => loansProviderMockLoans);

      await provider.loadLoans();

      expect(provider.loans.length, 2);
      expect(provider.totalLoanAmount, 300);
      expect(provider.totalDebtAmount, 100);
      expect(provider.netBalance, 200);
    });

    test('setSearchKeyword reloads current list', () async {
      when(
        () => loansService.getLoans(type: null, search: null, pageSize: 100),
      ).thenAnswer((_) async => loansProviderMockLoans);

      await provider.setSearchKeyword('  abc  ');

      expect(provider.loans.length, 2);
      verify(
        () => loansService.getLoans(type: null, search: null, pageSize: 100),
      ).called(1);
    });

    test('addLoan success refreshes list', () async {
      final date = DateTime.parse('2026-04-03T00:00:00Z');
      final dueDate = DateTime.parse('2026-06-15T00:00:00Z');

      when(
        () => loansService.createLoan(
          name: 'Borrow from C',
          type: 1,
          amount: 200,
          date: date,
          dueDate: dueDate,
          note: '',
        ),
      ).thenAnswer((_) async => loansProviderUpdatedList.last);

      when(
        () => loansService.getLoans(type: null, search: null, pageSize: 100),
      ).thenAnswer((_) async => loansProviderUpdatedList);

      final result = await provider.addLoan(
        name: 'Borrow from C',
        type: 1,
        amount: 200,
        date: date,
        dueDate: dueDate,
      );

      expect(result, true);
      expect(provider.loans.length, 3);
    });

    test('deleteLoan success removes local item', () async {
      when(
        () => loansService.getLoans(type: null, search: null, pageSize: 100),
      ).thenAnswer((_) async => loansProviderMockLoans);
      await provider.loadLoans();

      when(() => loansService.deleteLoan('l-loan')).thenAnswer((_) async => true);

      final result = await provider.deleteLoan('l-loan');

      expect(result, true);
      expect(provider.loans.any((e) => e.id == 'l-loan'), false);
    });
  });
}
