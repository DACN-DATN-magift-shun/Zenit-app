import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/features/transfer/models/money_transfer_model.dart';
import '../../../mocks/features/transfer/money_transfer_model_mock_data.dart';
import '../../../mocks/json_source_mock.dart';

void main() {
  group('MoneyTransferModel', () {
    test('fromJson parses wrapped payload and nested wallets', () {
      final source = MockJsonSource();
      when(() => source.value).thenReturn(moneyTransferFromJsonMockData);

      final model = MoneyTransferModel.fromJson(source.value);

      expect(model.id, 'mt1');
      expect(model.amount, 100000);
      expect(model.fromWallet?.id, 'w1');
      expect(model.toWallet?.name, 'Bank');
    });

    test('toCreateJson and toPatchJson serialize expected fields', () {
      final model = MoneyTransferModel(
        id: 'mt2',
        fromWalletId: 'a',
        toWalletId: 'b',
        amount: 500,
        transferDate: DateTime.parse('2026-04-26T01:00:00Z'),
        note: 'n',
      );

      final createJson = model.toCreateJson();
      final patchJson = model.toPatchJson();

      expect(createJson.containsKey('id'), false);
      expect(patchJson['id'], 'mt2');
      expect(createJson['fromWalletId'], 'a');
    });

    test('MoneyTransferListResponse.fromJson maps list and meta', () {
      final source = MockJsonSource();
      when(() => source.value).thenReturn(moneyTransferListResponseMockData);

      final response = MoneyTransferListResponse.fromJson(source.value);

      expect(response.items.length, 1);
      expect(response.meta.totalItems, 1);
      expect(response.meta.page, 1);
    });
  });
}
