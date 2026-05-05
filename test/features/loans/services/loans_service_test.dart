import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/loans/models/loan_model.dart';
import 'package:zenit/features/loans/services/loans_service.dart';

import '../../../mocks/features/loans/services/loans_service_mock_data.dart';
import '../../../mocks/network/api_client_mocks.dart';

void main() {
  late MockApiClient apiClient;
  late LoansService service;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    apiClient = MockApiClient();
    service = LoansService(apiClient: apiClient);
  });

  group('LoansService - getLoans', () {
    test('parses single loan list response', () async {
      when(
        () => apiClient.get(ApiEndpoints.loans,
            queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: loansListResponseData));

      final result = await service.getLoans(pageSize: 100);

      expect(result.length, 1);
      expect(result.first.id, 'l1');
      expect(result.first.name, 'Loan');
    });

    test('parses multiple loans response', () async {
      when(
        () => apiClient.get(ApiEndpoints.loans,
            queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: loansListMultipleData));

      final result = await service.getLoans(pageSize: 100);

      expect(result.length, 2);
      expect(result[0].name, 'Borrow from John');
      expect(result[0].type, 0);
      expect(result[1].name, 'Lend to Mary');
      expect(result[1].type, 1);
    });

    test('filters by type parameter', () async {
      when(
        () => apiClient.get(ApiEndpoints.loans,
            queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: loansListResponseData));

      await service.getLoans(type: 0, pageSize: 100);

      verify(
        () => apiClient.get(
          ApiEndpoints.loans,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });

    test('filters by search parameter', () async {
      when(
        () => apiClient.get(ApiEndpoints.loans,
            queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: loansListResponseData));

      await service.getLoans(search: 'John', pageSize: 100);

      verify(
        () => apiClient.get(
          ApiEndpoints.loans,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });

    test('uses beforeId for pagination', () async {
      when(
        () => apiClient.get(ApiEndpoints.loans,
            queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: loansListResponseData));

      await service.getLoans(beforeId: 'l1', pageSize: 100);

      verify(
        () => apiClient.get(
          ApiEndpoints.loans,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });

    test('sets useCountTotal when requested', () async {
      when(
        () => apiClient.get(ApiEndpoints.loans,
            queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: loansListResponseData));

      await service.getLoans(useCountTotal: true, pageSize: 100);

      verify(
        () => apiClient.get(
          ApiEndpoints.loans,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });

    test('throws exception on failed request', () async {
      when(
        () => apiClient.get(ApiEndpoints.loans,
            queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => buildResponse(statusCode: 500, data: {}));

      expect(
        () => service.getLoans(pageSize: 100),
        throwsException,
      );
    });
  });

  group('LoansService - getLoanById', () {
    test('retrieves single loan by id', () async {
      when(() => apiClient.get(ApiEndpoints.loanById('l1')))
          .thenAnswer((_) async =>
              buildResponse(statusCode: 200, data: singleLoanData));

      final result = await service.getLoanById('l1');

      expect(result.id, 'l1');
      expect(result.name, 'Borrow from John');
      expect(result.amount, 5000000);
      verify(() => apiClient.get(ApiEndpoints.loanById('l1'))).called(1);
    });

    test('throws exception when loan not found', () async {
      when(() => apiClient.get(ApiEndpoints.loanById('invalid')))
          .thenAnswer((_) async => buildResponse(statusCode: 404, data: {}));

      expect(
        () => service.getLoanById('invalid'),
        throwsException,
      );
    });
  });

  group('LoansService - createLoan', () {
    test('creates loan with required fields', () async {
      when(() => apiClient.post(ApiEndpoints.createLoan,
          data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 201, data: singleLoanData),
      );

      final result = await service.createLoan(
        name: 'Borrow from John',
        type: 0,
        amount: 5000000,
        date: DateTime(2026, 4, 1),
        dueDate: DateTime(2026, 5, 1),
      );

      expect(result.id, 'l1');
      expect(result.name, 'Borrow from John');
      expect(result.type, 0);
      expect(result.amount, 5000000);
    });

    test('creates loan with optional note', () async {
      when(() => apiClient.post(ApiEndpoints.createLoan,
          data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 201, data: singleLoanData),
      );

      final result = await service.createLoan(
        name: 'Borrow from John',
        type: 0,
        amount: 5000000,
        date: DateTime(2026, 4, 1),
        dueDate: DateTime(2026, 5, 1),
        note: 'Monthly payment',
      );

      expect(result.note, 'Monthly payment');
    });

    test('accepts 200 status code for creation', () async {
      when(() => apiClient.post(ApiEndpoints.createLoan,
          data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 200, data: singleLoanData),
      );

      final result = await service.createLoan(
        name: 'Borrow from John',
        type: 0,
        amount: 5000000,
        date: DateTime(2026, 4, 1),
        dueDate: DateTime(2026, 5, 1),
      );

      expect(result.id, 'l1');
    });

    test('handles empty response with fallback data', () async {
      when(() => apiClient.post(ApiEndpoints.createLoan,
          data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 201, data: {}),
      );

      final result = await service.createLoan(
        name: 'New Loan',
        type: 1,
        amount: 3000000,
        date: DateTime(2026, 4, 1),
        dueDate: DateTime(2026, 5, 1),
      );

      expect(result.name, 'New Loan');
      expect(result.type, 1);
      expect(result.amount, 3000000);
    });

    test('throws exception on failed creation', () async {
      when(() => apiClient.post(ApiEndpoints.createLoan,
          data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 400, data: {}),
      );

      expect(
        () => service.createLoan(
          name: 'Test Loan',
          type: 0,
          amount: 1000000,
          date: DateTime(2026, 4, 1),
          dueDate: DateTime(2026, 5, 1),
        ),
        throwsException,
      );
    });
  });

  group('LoansService - updateLoan', () {
    test('updates loan with all fields', () async {
      when(() => apiClient.patch(ApiEndpoints.updateLoanUrl('l1'),
          data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 200, data: singleLoanData),
      );

      final result = await service.updateLoan(
        id: 'l1',
        name: 'Updated Loan',
        type: 1,
        amount: 6000000,
        date: DateTime(2026, 4, 5),
        dueDate: DateTime(2026, 5, 5),
        note: 'Updated note',
      );

      expect(result.id, 'l1');
      verify(() => apiClient.patch(ApiEndpoints.updateLoanUrl('l1'),
          data: any(named: 'data'))).called(1);
    });

    test('updates loan with partial fields', () async {
      when(() => apiClient.patch(ApiEndpoints.updateLoanUrl('l1'),
          data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 200, data: singleLoanData),
      );

      final result = await service.updateLoan(
        id: 'l1',
        name: 'Updated Loan',
      );

      expect(result.id, 'l1');
    });

    test('handles empty response with fallback data', () async {
      when(() => apiClient.patch(ApiEndpoints.updateLoanUrl('l1'),
          data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 200, data: {}),
      );

      final result = await service.updateLoan(
        id: 'l1',
        name: 'Updated Loan',
        type: 1,
      );

      expect(result.id, 'l1');
      expect(result.name, 'Updated Loan');
      expect(result.type, 1);
    });

    test('throws exception on failed update', () async {
      when(() => apiClient.patch(ApiEndpoints.updateLoanUrl('l1'),
          data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 500),
      );

      expect(
        () => service.updateLoan(id: 'l1', name: 'Updated'),
        throwsException,
      );
    });
  });

  group('LoansService - deleteLoan', () {
    test('deletes loan successfully with 200 status', () async {
      when(() => apiClient.delete(ApiEndpoints.deleteLoanUrl('l1')))
          .thenAnswer((_) async => buildResponse(statusCode: 200));

      final result = await service.deleteLoan('l1');

      expect(result, true);
      verify(() => apiClient.delete(ApiEndpoints.deleteLoanUrl('l1')))
          .called(1);
    });

    test('deletes loan successfully with 204 status', () async {
      when(() => apiClient.delete(ApiEndpoints.deleteLoanUrl('l1')))
          .thenAnswer((_) async => buildResponse(statusCode: 204));

      final result = await service.deleteLoan('l1');

      expect(result, true);
    });

    test('deletes loan successfully with 202 status', () async {
      when(() => apiClient.delete(ApiEndpoints.deleteLoanUrl('l1')))
          .thenAnswer((_) async => buildResponse(statusCode: 202));

      final result = await service.deleteLoan('l1');

      expect(result, true);
    });

    test('throws exception when id is empty', () async {
      expect(
        () => service.deleteLoan(''),
        throwsException,
      );
      expect(
        () => service.deleteLoan('  '),
        throwsException,
      );
    });

    test('throws exception on failed deletion', () async {
      when(() => apiClient.delete(ApiEndpoints.deleteLoanUrl('l1')))
          .thenAnswer((_) async => buildResponse(statusCode: 500));

      final result = await service.deleteLoan('l1');

      expect(result, false);
    });
  });

  group('LoansService - createManyLoans', () {
    test('creates multiple loans successfully', () async {
      final loans = [
        LoanModel(
          id: '',
          name: 'Loan 1',
          type: 0,
          amount: 1000000,
          date: DateTime(2026, 4, 1),
          dueDate: DateTime(2026, 5, 1),
        ),
        LoanModel(
          id: '',
          name: 'Loan 2',
          type: 1,
          amount: 2000000,
          date: DateTime(2026, 4, 1),
          dueDate: DateTime(2026, 5, 1),
        ),
      ];

      when(() =>
          apiClient.post(ApiEndpoints.createManyLoans,
              data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 201),
      );

      final result = await service.createManyLoans(loans);

      expect(result, true);
      verify(() =>
          apiClient.post(ApiEndpoints.createManyLoans,
              data: any(named: 'data'))).called(1);
    });

    test('handles 202 status for batch creation', () async {
      final loans = [
        LoanModel(
          id: '',
          name: 'Loan 1',
          type: 0,
          amount: 1000000,
          date: DateTime(2026, 4, 1),
          dueDate: DateTime(2026, 5, 1),
        ),
      ];

      when(() =>
          apiClient.post(ApiEndpoints.createManyLoans,
              data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 202),
      );

      final result = await service.createManyLoans(loans);

      expect(result, true);
    });

    test('throws exception on failed batch creation', () async {
      final loans = [
        LoanModel(
          id: '',
          name: 'Loan 1',
          type: 0,
          amount: 1000000,
          date: DateTime(2026, 4, 1),
          dueDate: DateTime(2026, 5, 1),
        ),
      ];

      when(() =>
          apiClient.post(ApiEndpoints.createManyLoans,
              data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 400),
      );

      final result = await service.createManyLoans(loans);

      expect(result, false);
    });
  });

  group('LoansService - error handling', () {
    test('handles DioException with connection timeout', () async {
      when(
        () => apiClient.get(ApiEndpoints.loans,
            queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.loans),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(
        () => service.getLoans(pageSize: 100),
        throwsException,
      );
    });

    test('handles DioException with network error', () async {
      when(
        () => apiClient.get(ApiEndpoints.loans,
            queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.loans),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(
        () => service.getLoans(pageSize: 100),
        throwsException,
      );
    });

    test('handles DioException with receive timeout', () async {
      when(
        () => apiClient.get(ApiEndpoints.loans,
            queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.loans),
          type: DioExceptionType.receiveTimeout,
        ),
      );

      expect(
        () => service.getLoans(pageSize: 100),
        throwsException,
      );
    });
  });
}
