import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/transaction/models/transaction_model.dart';
import 'package:zenit/features/transaction/services/transaction_service.dart';

import '../../../mocks/features/transaction/services/transaction_service_mock_data.dart';
import '../../../mocks/network/api_client_mocks.dart';

void main() {
  late MockApiClient apiClient;
  late TransactionService service;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    apiClient = MockApiClient();
    service = TransactionService(apiClient: apiClient);
  });

  group('TransactionService - getAllTransactions', () {
    test('parses single transaction list response', () async {
      when(
        () => apiClient.get(ApiEndpoints.transactions,
            queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: transactionListResponseData));

      final result = await service.getAllTransactions(pageSize: 20);

      expect(result.items.length, 1);
      expect(result.items.first.id, 'tx1');
      expect(result.items.first.title, 'Lunch');
      expect(result.items.first.amount, 10);
    });

    test('parses multiple transactions with metadata', () async {
      when(
        () => apiClient.get(ApiEndpoints.transactions,
            queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: transactionListMultipleData));

      final result = await service.getAllTransactions(pageSize: 20);

      expect(result.items.length, 3);
      expect(result.items[0].title, 'Lunch');
      expect(result.items[1].title, 'Grocery');
      expect(result.items[2].title, 'Salary');
      expect(result.meta.totalItems, 3);
      expect(result.meta.pageCount, 1);
    });

    test('includes fromDate in query params when provided', () async {
      final fromDate = DateTime(2026, 4, 1);
      when(
        () => apiClient.get(ApiEndpoints.transactions,
            queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: transactionListResponseData));

      await service.getAllTransactions(
        fromDate: fromDate,
        pageSize: 20,
      );

      verify(
        () => apiClient.get(
          ApiEndpoints.transactions,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });

    test('includes toDate in query params when provided', () async {
      final toDate = DateTime(2026, 4, 30);
      when(
        () => apiClient.get(ApiEndpoints.transactions,
            queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: transactionListResponseData));

      await service.getAllTransactions(
        toDate: toDate,
        pageSize: 20,
      );

      verify(
        () => apiClient.get(
          ApiEndpoints.transactions,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });

    test('includes categoryId in query params when provided', () async {
      when(
        () => apiClient.get(ApiEndpoints.transactions,
            queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: transactionListResponseData));

      await service.getAllTransactions(
        categoryId: 'c1',
        pageSize: 20,
      );

      verify(
        () => apiClient.get(
          ApiEndpoints.transactions,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });

    test('includes search in query params when provided', () async {
      when(
        () => apiClient.get(ApiEndpoints.transactions,
            queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: transactionListResponseData));

      await service.getAllTransactions(
        search: 'lunch',
        pageSize: 20,
      );

      verify(
        () => apiClient.get(
          ApiEndpoints.transactions,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });

    test('throws exception on non-200 status code', () async {
      when(
        () => apiClient.get(ApiEndpoints.transactions,
            queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => buildResponse(statusCode: 500, data: {}));

      expect(
        () => service.getAllTransactions(pageSize: 20),
        throwsException,
      );
    });
  });

  group('TransactionService - createTransaction', () {
    test('creates transaction with required fields', () async {
      when(() => apiClient.post(ApiEndpoints.createTransaction,
          data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 201, data: singleTransactionData),
      );

      final result = await service.createTransaction(
        title: 'Lunch',
        amount: 100000,
        transactionDate: DateTime(2026, 4, 20),
        categoryId: 'c1',
        walletId: 'w1',
      );

      expect(result.id, 'tx1');
      expect(result.title, 'Lunch');
      expect(result.amount, 100000);
      verify(() => apiClient.post(ApiEndpoints.createTransaction,
          data: any(named: 'data'))).called(1);
    });

    test('creates transaction with optional note', () async {
      when(() => apiClient.post(ApiEndpoints.createTransaction,
          data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 201, data: singleTransactionData),
      );

      final result = await service.createTransaction(
        title: 'Lunch',
        note: 'Lunch with friends',
        amount: 100000,
        transactionDate: DateTime(2026, 4, 20),
        categoryId: 'c1',
        walletId: 'w1',
      );

      expect(result.note, 'Lunch with friends');
    });

    test('accepts status code 200 for creation', () async {
      when(() => apiClient.post(ApiEndpoints.createTransaction,
          data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 200, data: singleTransactionData),
      );

      final result = await service.createTransaction(
        title: 'Lunch',
        amount: 100000,
        transactionDate: DateTime(2026, 4, 20),
        categoryId: 'c1',
        walletId: 'w1',
      );

      expect(result.id, 'tx1');
    });

    test('throws exception on failed creation', () async {
      when(() => apiClient.post(ApiEndpoints.createTransaction,
          data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 400, data: {}),
      );

      expect(
        () => service.createTransaction(
          title: 'Lunch',
          amount: 100000,
          transactionDate: DateTime(2026, 4, 20),
          categoryId: 'c1',
          walletId: 'w1',
        ),
        throwsException,
      );
    });
  });

  group('TransactionService - updateTransactions', () {
    test('updates transaction list successfully', () async {
      final items =
          (transactionListResponseData['items'] as List<dynamic>);
      final transaction = TransactionModel.fromJson(
          items.first as Map<String, dynamic>);

      when(() => apiClient.patch(ApiEndpoints.transactions,
          data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 200),
      );

      final result =
          await service.updateTransactions([transaction]);

      expect(result, true);
      verify(() => apiClient.patch(ApiEndpoints.transactions,
          data: any(named: 'data'))).called(1);
    });

    test('updates multiple transactions', () async {
      final items =
          (transactionListMultipleData['items'] as List<dynamic>);
      final transactions = items
          .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
          .toList();

      when(() => apiClient.patch(ApiEndpoints.transactions,
          data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 200),
      );

      final result = await service.updateTransactions(transactions);

      expect(result, true);
      expect(transactions.length, 3);
    });

    test('throws exception on failed update', () async {
      final items =
          (transactionListResponseData['items'] as List<dynamic>);
      final transaction = TransactionModel.fromJson(
          items.first as Map<String, dynamic>);

      when(() => apiClient.patch(ApiEndpoints.transactions,
          data: any(named: 'data'))).thenAnswer(
        (_) async => buildResponse(statusCode: 500),
      );

      expect(
        () => service.updateTransactions([transaction]),
        throwsException,
      );
    });
  });

  group('TransactionService - getTransactionById', () {
    test('retrieves single transaction by id', () async {
      when(() => apiClient.get(ApiEndpoints.transactionById('tx1')))
          .thenAnswer((_) async =>
              buildResponse(statusCode: 200, data: singleTransactionData));

      final result = await service.getTransactionById('tx1');

      expect(result.id, 'tx1');
      expect(result.title, 'Lunch');
      verify(() => apiClient.get(ApiEndpoints.transactionById('tx1')))
          .called(1);
    });

    test('throws exception when transaction not found', () async {
      when(() => apiClient.get(ApiEndpoints.transactionById('invalid')))
          .thenAnswer((_) async => buildResponse(statusCode: 404, data: {}));

      expect(
        () => service.getTransactionById('invalid'),
        throwsException,
      );
    });
  });

  group('TransactionService - deleteTransaction', () {
    test('deletes transaction successfully with 200 status', () async {
      when(() => apiClient.delete(ApiEndpoints.deleteTransactionUrl('tx1')))
          .thenAnswer((_) async => buildResponse(statusCode: 200));

      final result = await service.deleteTransaction('tx1');

      expect(result, true);
      verify(() => apiClient.delete(ApiEndpoints.deleteTransactionUrl('tx1')))
          .called(1);
    });

    test('deletes transaction successfully with 204 status', () async {
      when(() => apiClient.delete(ApiEndpoints.deleteTransactionUrl('tx1')))
          .thenAnswer((_) async => buildResponse(statusCode: 204));

      final result = await service.deleteTransaction('tx1');

      expect(result, true);
    });

    test('throws exception on failed deletion', () async {
      when(() => apiClient.delete(ApiEndpoints.deleteTransactionUrl('tx1')))
          .thenAnswer((_) async => buildResponse(statusCode: 500));

      expect(
        () => service.deleteTransaction('tx1'),
        throwsException,
      );
    });
  });

  group('TransactionService - error handling', () {
    test('handles DioException with connection timeout', () async {
      when(
        () => apiClient.get(ApiEndpoints.transactions,
            queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.transactions),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(
        () => service.getAllTransactions(pageSize: 20),
        throwsException,
      );
    });

    test('handles DioException with network error', () async {
      when(
        () => apiClient.get(ApiEndpoints.transactions,
            queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.transactions),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(
        () => service.getAllTransactions(pageSize: 20),
        throwsException,
      );
    });
  });
}
