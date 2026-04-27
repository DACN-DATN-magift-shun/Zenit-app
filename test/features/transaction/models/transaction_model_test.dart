import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/features/transaction/models/transaction_model.dart';
import '../../../mocks/features/transaction/transaction_model_mock_data.dart';
import '../../../mocks/json_source_mock.dart';

void main() {
  group('TransactionModel', () {
    test('fromJson unwraps payload and parses nested fields', () {
      final source = MockJsonSource();
      when(() => source.value).thenReturn(transactionFromJsonMockData);

      final model = TransactionModel.fromJson(source.value);

      expect(model.id, 't1');
      expect(model.walletId, 'w-from-nested');
      expect(model.amount, 120000);
      expect(model.firstPhotoUrl, 'https://cdn/p1.jpg');
    });

    test('toJsonWithId includes id and payload fields', () {
      final model = TransactionModel(
        id: 't2',
        title: 'Coffee',
        amount: 30000,
        transactionDate: DateTime.parse('2026-04-26T00:00:00Z'),
        categoryId: 'cat',
        walletId: 'wal',
      );

      final json = model.toJsonWithId();

      expect(json['id'], 't2');
      expect(json['title'], 'Coffee');
      expect(json['walletId'], 'wal');
    });

    test('TransactionListResponse.fromJson parses items and meta', () {
      final source = MockJsonSource();
      when(() => source.value).thenReturn(transactionListResponseMockData);

      final response = TransactionListResponse.fromJson(source.value);

      expect(response.items.length, 1);
      expect(response.items.first.id, 'tx1');
      expect(response.meta.pageSize, 10);
    });
  });
}
