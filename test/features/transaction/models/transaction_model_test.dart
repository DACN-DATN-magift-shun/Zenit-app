import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/features/transaction/models/transaction_model.dart';
import '../../../mocks/features/transaction/transaction_model_mock_data.dart';

void main() {
  group('TransactionModel.fromJson - Payload Unwrapping', () {
    test('unwraps data wrapper', () {
      final model = TransactionModel.fromJson(transactionFromJsonMockData);

      expect(model.id, 't1');
      expect(model.title, 'Lunch');
      expect(model.note, 'team meal');
      expect(model.amount, 120000);
    });

    test('unwraps result wrapper', () {
      final model = TransactionModel.fromJson(transactionResultWrapper);

      expect(model.id, 't2');
      expect(model.title, 'Dinner');
      expect(model.amount, 200000);
    });

    test('unwraps transaction wrapper', () {
      final model = TransactionModel.fromJson(transactionTransactionWrapper);

      expect(model.id, 't3');
      expect(model.title, 'Coffee');
    });

    test('unwraps item wrapper', () {
      final model = TransactionModel.fromJson(transactionItemWrapper);

      expect(model.id, 't4');
      expect(model.title, 'Snack');
    });

    test('unwraps record wrapper', () {
      final model = TransactionModel.fromJson(transactionRecordWrapper);

      expect(model.id, 't5');
      expect(model.title, 'Dessert');
    });

    test('unwraps entity wrapper', () {
      final model = TransactionModel.fromJson(transactionEntityWrapper);

      expect(model.id, 't6');
      expect(model.title, 'Beverage');
    });
  });

  group('TransactionModel.fromJson - Field Parsing', () {
    test('parses all fields correctly', () {
      final model = TransactionModel.fromJson(fullTransactionData);

      expect(model.id, 't_full');
      expect(model.title, 'Full Transaction');
      expect(model.note, 'Complete info');
      expect(model.amount, 500000);
      expect(model.categoryId, 'c1');
      expect(model.walletId, 'w1');
      expect(model.accountId, 'acc123');
      expect(model.createdById, 'user1');
      expect(model.isDeleted, false);
      expect(model.modifiedById, 'user2');
    });

    test('parses transaction date correctly', () {
      final model = TransactionModel.fromJson(fullTransactionData);

      expect(model.transactionDate.year, 2026);
      expect(model.transactionDate.month, 4);
      expect(model.transactionDate.day, 20);
    });

    test('parses category with all fields', () {
      final model = TransactionModel.fromJson(fullTransactionData);

      expect(model.category, isNotNull);
      expect(model.category!.id, 'c1');
      expect(model.category!.name, 'Food');
      expect(model.category!.icon, 'restaurant');
      expect(model.category!.groupType, 0);
    });

    test('handles deleted transaction', () {
      final model = TransactionModel.fromJson(deletedTransactionData);

      expect(model.isDeleted, true);
      expect(model.deletedById, 'user3');
      expect(model.deletedAt, isNotNull);
    });

    test('handles minimal transaction', () {
      final model = TransactionModel.fromJson(minimalTransactionData);

      expect(model.id, 't_min');
      expect(model.title, 'Minimal');
      expect(model.note, isNull);
      expect(model.category, isNull);
      expect(model.accountId, isNull);
    });

    test('handles default values', () {
      final model = TransactionModel.fromJson({'title': 'Test'});

      expect(model.title, 'Test');
      expect(model.amount, 0);
      expect(model.categoryId, '');
      expect(model.walletId, '');
      expect(model.isDeleted, false);
      expect(model.photos.isEmpty, true);
    });
  });

  group('TransactionModel.fromJson - ID Parsing', () {
    test('finds id with different key names', () {
      final model1 = TransactionModel.fromJson({'id': 't1', 'title': 'Test'});
      expect(model1.id, 't1');

      final model2 = TransactionModel.fromJson({
        'transactionId': 't2',
        'title': 'Test',
      });
      expect(model2.id, 't2');

      final model3 = TransactionModel.fromJson({
        'transactionID': 't3',
        'title': 'Test',
      });
      expect(model3.id, 't3');
    });
  });

  group('TransactionModel.fromJson - Wallet ID Parsing', () {
    test('finds walletId with different key names', () {
      final model1 =
          TransactionModel.fromJson({'walletId': 'w1', 'title': 'Test'});
      expect(model1.walletId, 'w1');

      final model2 =
          TransactionModel.fromJson({'walletID': 'w2', 'title': 'Test'});
      expect(model2.walletId, 'w2');

      final model3 =
          TransactionModel.fromJson({'wallet_id': 'w3', 'title': 'Test'});
      expect(model3.walletId, 'w3');
    });

    test('finds walletId from nested wallet object', () {
      final model = TransactionModel.fromJson({
        'wallet': {'id': 'w-nested'},
        'title': 'Test',
      });
      expect(model.walletId, 'w-nested');
    });
  });

  group('TransactionModel.fromJson - Photos Parsing', () {
    test('parses multiple photos', () {
      final model = TransactionModel.fromJson(transactionWithPhotos);

      expect(model.photos.length, 3);
      expect(model.photos[0].url, 'https://cdn/p1.jpg');
      expect(model.photos[1].url, 'https://cdn/p2.jpg');
      expect(model.photos[2].url, 'https://cdn/p3.jpg');
    });

    test('handles empty photos list', () {
      final model = TransactionModel.fromJson(transactionNoPhotos);

      expect(model.photos.isEmpty, true);
    });

    test('handles no photos field', () {
      final model = TransactionModel.fromJson(minimalTransactionData);

      expect(model.photos.isEmpty, true);
    });

    test('firstPhotoUrl returns first non-empty photo', () {
      final model = TransactionModel.fromJson(transactionWithPhotos);

      expect(model.firstPhotoUrl, 'https://cdn/p1.jpg');
    });

    test('firstPhotoUrl returns null when no photos', () {
      final model = TransactionModel.fromJson(transactionNoPhotos);

      expect(model.firstPhotoUrl, isNull);
    });

    test('firstPhotoUrl from single photo in data wrapper', () {
      final model = TransactionModel.fromJson(transactionFromJsonMockData);

      expect(model.firstPhotoUrl, 'https://cdn/p1.jpg');
    });
  });

  group('TransactionModel.fromJson - Type Conversions', () {
    test('converts string amount to int', () {
      final model = TransactionModel.fromJson({
        'title': 'Test',
        'amount': '50000',
      });

      expect(model.amount, 50000);
      expect(model.amount is int, true);
    });

    test('converts double amount to int', () {
      final model = TransactionModel.fromJson({
        'title': 'Test',
        'amount': 50000.5,
      });

      expect(model.amount, 50000);
    });

    test('handles invalid amount string', () {
      final model = TransactionModel.fromJson({
        'title': 'Test',
        'amount': 'invalid',
      });

      expect(model.amount, 0);
    });

    test('parses datetime strings', () {
      final model = TransactionModel.fromJson({
        'title': 'Test',
        'transactionDate': '2026-04-25T12:00:00Z',
      });

      expect(model.transactionDate.year, 2026);
      expect(model.transactionDate.month, 4);
    });

    test('handles invalid datetime string', () {
      final model = TransactionModel.fromJson({
        'title': 'Test',
        'transactionDate': 'invalid-date',
      });

      expect(model.transactionDate is DateTime, true);
    });
  });

  group('TransactionModel - Serialization', () {
    test('toJson includes required fields', () {
      final model = TransactionModel(
        id: 't1',
        title: 'Test',
        amount: 100000,
        transactionDate: DateTime.parse('2026-04-25T00:00:00Z'),
        categoryId: 'c1',
        walletId: 'w1',
      );

      final json = model.toJson();

      expect(json['title'], 'Test');
      expect(json['amount'], 100000);
      expect(json['categoryId'], 'c1');
      expect(json['walletId'], 'w1');
      expect(json['note'], '');
    });

    test('toJsonWithId includes id', () {
      final model = TransactionModel(
        id: 't1',
        title: 'Coffee',
        amount: 30000,
        transactionDate: DateTime.parse('2026-04-26T00:00:00Z'),
        categoryId: 'cat',
        walletId: 'wal',
      );

      final json = model.toJsonWithId();

      expect(json['id'], 't1');
      expect(json['title'], 'Coffee');
      expect(json['walletId'], 'wal');
    });

    test('toJsonForDetail includes all fields', () {
      final model = TransactionModel(
        id: 't1',
        title: 'Test',
        note: 'Detail note',
        amount: 100000,
        transactionDate: DateTime.parse('2026-04-25T00:00:00Z'),
        categoryId: 'c1',
        walletId: 'w1',
        accountId: 'acc1',
        createdById: 'user1',
        isDeleted: false,
      );

      final json = model.toJsonForDetail();

      expect(json['id'], 't1');
      expect(json['title'], 'Test');
      expect(json['accountId'], 'acc1');
      expect(json['createdById'], 'user1');
      expect(json['isDeleted'], false);
    });

    test('toJsonForDetail includes category', () {
      final category = TransactionCategoryModel(
        id: 'c1',
        name: 'Food',
        icon: 'restaurant',
        color: '#FF5722',
        backgroundColor: '#FFEBEE',
        groupType: 0,
      );

      final model = TransactionModel(
        id: 't1',
        title: 'Test',
        amount: 100000,
        transactionDate: DateTime.parse('2026-04-25T00:00:00Z'),
        categoryId: 'c1',
        walletId: 'w1',
        category: category,
      );

      final json = model.toJsonForDetail();

      expect(json['category'], isNotNull);
      expect(json['category']['id'], 'c1');
      expect(json['category']['name'], 'Food');
    });

    test('toJsonForDetail includes photos', () {
      final model = TransactionModel.fromJson(transactionWithPhotos);
      final json = model.toJsonForDetail();

      expect(json['photos'], isNotNull);
      expect((json['photos'] as List).length, 3);
    });
  });

  group('TransactionModel - copyWith', () {
    test('copies with new title', () {
      final original = TransactionModel(
        id: 't1',
        title: 'Original',
        amount: 100000,
        transactionDate: DateTime.parse('2026-04-25T00:00:00Z'),
        categoryId: 'c1',
        walletId: 'w1',
      );

      final copied = original.copyWith(title: 'Updated');

      expect(copied.title, 'Updated');
      expect(copied.amount, original.amount);
      expect(copied.id, original.id);
    });

    test('copies with new amount', () {
      final original = TransactionModel(
        id: 't1',
        title: 'Test',
        amount: 100000,
        transactionDate: DateTime.parse('2026-04-25T00:00:00Z'),
        categoryId: 'c1',
        walletId: 'w1',
      );

      final copied = original.copyWith(amount: 200000);

      expect(copied.amount, 200000);
      expect(copied.title, original.title);
    });

    test('copies all fields', () {
      final date = DateTime.parse('2026-04-25T00:00:00Z');
      final newDate = DateTime.parse('2026-04-26T00:00:00Z');

      final original = TransactionModel(
        id: 't1',
        title: 'Test',
        note: 'Note',
        amount: 100000,
        transactionDate: date,
        categoryId: 'c1',
        walletId: 'w1',
        isDeleted: false,
      );

      final copied = original.copyWith(
        title: 'New Title',
        amount: 200000,
        transactionDate: newDate,
        categoryId: 'c2',
        isDeleted: true,
      );

      expect(copied.title, 'New Title');
      expect(copied.amount, 200000);
      expect(copied.transactionDate, newDate);
      expect(copied.categoryId, 'c2');
      expect(copied.isDeleted, true);
      expect(copied.note, original.note);
    });
  });

  group('TransactionMetaModel', () {
    test('parses metadata from json', () {
      final meta = TransactionMetaModel.fromJson({
        'totalItems': 100,
        'pageCount': 10,
        'page': 1,
        'pageSize': 10,
      });

      expect(meta.totalItems, 100);
      expect(meta.pageCount, 10);
      expect(meta.page, 1);
      expect(meta.pageSize, 10);
    });

    test('handles missing page field', () {
      final meta = TransactionMetaModel.fromJson({
        'totalItems': 100,
        'pageCount': 10,
        'pageSize': 10,
      });

      expect(meta.page, isNull);
    });

    test('converts string values to int', () {
      final meta = TransactionMetaModel.fromJson({
        'totalItems': '100',
        'pageCount': '10',
        'pageSize': '10',
      });

      expect(meta.totalItems, 100);
      expect(meta.pageCount, 10);
    });
  });

  group('TransactionListResponse', () {
    test('parses list response with single item', () {
      final response = TransactionListResponse.fromJson(
          transactionListResponseMockData);

      expect(response.items.length, 1);
      expect(response.items.first.id, 'tx1');
      expect(response.meta.totalItems, 1);
    });

    test('parses list response with multiple items', () {
      final response = TransactionListResponse.fromJson(
          transactionListMultipleData);

      expect(response.items.length, 3);
      expect(response.items[0].title, 'Breakfast');
      expect(response.items[1].title, 'Lunch');
      expect(response.items[2].title, 'Dinner');
      expect(response.meta.pageSize, 10);
    });

    test('parses metadata correctly', () {
      final response = TransactionListResponse.fromJson(
          transactionListMultipleData);

      expect(response.meta.totalItems, 3);
      expect(response.meta.pageCount, 1);
      expect(response.meta.page, 1);
    });

    test('handles data unwrapping in list response', () {
      final response = TransactionListResponse.fromJson({
        'data': {
          'items': [
            {
              'id': 'tx1',
              'title': 'Test',
              'amount': 100,
            },
          ],
          'meta': {
            'totalItems': 1,
            'pageCount': 1,
            'pageSize': 10,
          },
        },
      });

      expect(response.items.length, 1);
      expect(response.items.first.title, 'Test');
    });
  });

  group('TransactionCategoryModel', () {
    test('parses category from json', () {
      final category = TransactionCategoryModel.fromJson({
        'id': 'c1',
        'name': 'Food',
        'icon': 'restaurant',
        'color': '#FF5722',
        'backgroundColor': '#FFEBEE',
        'groupType': 0,
      });

      expect(category.id, 'c1');
      expect(category.name, 'Food');
      expect(category.groupType, 0);
    });

    test('handles default color values', () {
      final category = TransactionCategoryModel.fromJson({
        'id': 'c1',
        'name': 'Food',
        'icon': 'restaurant',
        'groupType': 0,
      });

      expect(category.color, '#FFFFFF');
      expect(category.backgroundColor, '#000000');
    });
  });

  group('TransactionModel - toString', () {
    test('returns readable string representation', () {
      final model = TransactionModel(
        id: 't1',
        title: 'Lunch',
        amount: 100000,
        transactionDate: DateTime.parse('2026-04-25T00:00:00Z'),
        categoryId: 'c1',
        walletId: 'w1',
      );

      final str = model.toString();

      expect(str.contains('t1'), true);
      expect(str.contains('Lunch'), true);
      expect(str.contains('100000'), true);
    });
  });
}
