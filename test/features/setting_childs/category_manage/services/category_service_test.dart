import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/setting_childs/category_manage/services/category_service.dart';

import '../../../../mocks/features/setting_childs/category_manage/services/category_service_mock_data.dart';
import '../../../../mocks/network/api_client_mocks.dart';

int _tryParseInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

void main() {
  late MockApiClient apiClient;
  late CategoryService service;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    apiClient = MockApiClient();
    service = CategoryService(apiClient: apiClient);
  });

  group('CategoryService - getCategoriesByGroupType', () {
    test('handles list payload format', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.categories,
          queryParameters: {
            'groupType': 0,
            'Page': 1,
            'PageSize': 10,
          },
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: categoryListAsListData));

      final result = await service.getCategoriesByGroupType(0);

      expect(result.type, 0);
      expect(result.categories.length, 1);
      expect(result.categories.first.id, 'c1');
      expect(result.categories.first.name, 'Food');
      expect(result.categories.first.expenseLimit, 5000000);
    });

    test('handles data format with list items', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.categories,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => buildResponse(
            statusCode: 200,
            data: {
              'data': [
                {
                  'id': 'c2',
                  'name': 'Transport',
                  'icon': 'directions_car',
                  'groupType': 0,
                  'color': '#222222',
                  'backgroundColor': '#DDDDDD',
                }
              ]
            },
          ));

      final result = await service.getCategoriesByGroupType(0);

      expect(result.categories.length, 1);
      expect(result.categories.first.id, 'c2');
      expect(result.categories.first.name, 'Transport');
    });

    test('handles nested items format', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.categories,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: categoryListNestedItemsFormat));

      final result = await service.getCategoriesByGroupType(0);

      expect(result.categories.length, 1);
      expect(result.categories.first.id, 'c3');
    });

    test('filters categories by groupType correctly', () async {
      // Create data with categories from groupType 0 and 5
      final responseData = {
        'items': [
          {
            'id': 'c1',
            'name': 'Food',
            'icon': 'restaurant',
            'groupType': '0',
            'color': '#111111',
            'backgroundColor': '#EEEEEE',
          },
          {
            'id': 'c2',
            'name': 'Transport',
            'icon': 'directions_car',
            'groupType': '0',
            'color': '#222222',
            'backgroundColor': '#DDDDDD',
          },
          {
            'id': 'c5',
            'name': 'Salary',
            'icon': 'attach_money',
            'groupType': '5',
            'color': '#555555',
            'backgroundColor': '#999999',
          },
        ]
      };

      when(
        () => apiClient.get(
          ApiEndpoints.categories,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => buildResponse(statusCode: 200, data: responseData));

      final result = await service.getCategoriesByGroupType(0);

      expect(result.type, 0);
      expect(result.categories.length, 2);
      expect(
        result.categories.every((c) =>
            _tryParseInt(c.groupType) == 0),
        true,
      );
    });

    test('returns empty group when api returns 404', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.categories,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      ));

      final result = await service.getCategoriesByGroupType(0);

      expect(result.type, 0);
      expect(result.categories.isEmpty, true);
    });

    test('returns empty group on non-200 status', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.categories,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 500, data: {'error': 'Server error'}));

      final result = await service.getCategoriesByGroupType(0);

      expect(result.type, 0);
      expect(result.categories.isEmpty, true);
    });

    test('retries when backend returns empty items with totalItems > 0', () async {
      final responses = [
        buildResponse(statusCode: 200, data: categoryEmptyWithMeta),
        buildResponse(statusCode: 200, data: categoryEmptyWithMetaRetry),
      ];
      var callCount = 0;

      when(
        () => apiClient.get(
          ApiEndpoints.categories,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => responses[callCount++]);

      final result = await service.getCategoriesByGroupType(0);

      expect(result.categories.length, 2);
      verify(
        () => apiClient.get(
          ApiEndpoints.categories,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(2);
    });

    test('throws for connection timeout', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.categories,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(
        () => service.getCategoriesByGroupType(0),
        throwsException,
      );
    });

    test('throws for receive timeout', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.categories,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(DioException(
        type: DioExceptionType.receiveTimeout,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(
        () => service.getCategoriesByGroupType(0),
        throwsException,
      );
    });

    test('returns correct group name for all groupTypes', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.categories,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: {'items': []}));

      for (int i = 0; i <= 5; i++) {
        final result = await service.getCategoriesByGroupType(i);
        expect(result.type, i);
      }
    });
  });

  group('CategoryService - getAllCategoriesByAllGroups', () {
    test('fetches all groupTypes in parallel', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.categories,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: {'items': []}));

      final result = await service.getAllCategoriesByAllGroups();

      expect(result.length, 6);
      for (int i = 0; i <= 5; i++) {
        expect(result.containsKey(i), true);
      }

      verify(
        () => apiClient.get(
          ApiEndpoints.categories,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(6);
    });

    test('populates all groups with different categories', () async {
      final responses = {
        0: buildResponse(
          statusCode: 200,
          data: {'items': categoryListAsListData},
        ),
        5: buildResponse(
          statusCode: 200,
          data: {'items': incomeCategories['items']},
        ),
      };

      var callCount = 0;
      when(
        () => apiClient.get(
          ApiEndpoints.categories,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async {
        final groupType = callCount ~/ 1;
        callCount++;
        return responses[groupType % 2] ??
            buildResponse(statusCode: 200, data: {'items': []});
      });

      final result = await service.getAllCategoriesByAllGroups();

      expect(result.length, 6);
    });
  });

  group('CategoryService - getCategoryById', () {
    test('fetches category by id', () async {
      when(
        () => apiClient.get(ApiEndpoints.categoryById('c1')),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: singleCategoryData));

      final result = await service.getCategoryById('c1');

      expect(result.id, 'c1');
      expect(result.name, 'Food');
      expect(result.expenseLimit, 5000000);
      verify(() => apiClient.get(ApiEndpoints.categoryById('c1'))).called(1);
    });

    test('throws on non-200 status', () async {
      when(
        () => apiClient.get(ApiEndpoints.categoryById('c_invalid')),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 404, data: {'error': 'Not found'}));

      expect(
        () => service.getCategoryById('c_invalid'),
        throwsException,
      );
    });

    test('throws on DioException', () async {
      when(
        () => apiClient.get(ApiEndpoints.categoryById('c1')),
      ).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      ));

      expect(
        () => service.getCategoryById('c1'),
        throwsException,
      );
    });
  });

  group('CategoryService - createCategory', () {
    test('creates category with all parameters', () async {
      when(
        () => apiClient.post(
          ApiEndpoints.createCategory,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 201, data: createCategoryResponse));

      final result = await service.createCategory(
        name: 'Shopping',
        icon: 'shopping_bag',
        color: '#FF0000',
        backgroundColor: '#FFE0E0',
        groupType: 0,
        expenseLimit: 10000000,
        expenseAlertThreshold: 8000000,
      );

      expect(result.id, 'c_new');
      expect(result.name, 'Shopping');
      verify(
        () => apiClient.post(
          ApiEndpoints.createCategory,
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test('creates category with minimum parameters', () async {
      when(
        () => apiClient.post(
          ApiEndpoints.createCategory,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: createCategoryResponse));

      final result = await service.createCategory(
        name: 'Shopping',
        icon: 'shopping_bag',
        color: '#FF0000',
        backgroundColor: '#FFE0E0',
        groupType: 0,
      );

      expect(result.id, 'c_new');
    });

    test('throws on non-2xx status', () async {
      when(
        () => apiClient.post(
          ApiEndpoints.createCategory,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 400, data: {'error': 'Invalid'}));

      expect(
        () => service.createCategory(
          name: 'Test',
          icon: 'test',
          color: '#000000',
          backgroundColor: '#FFFFFF',
          groupType: 0,
        ),
        throwsException,
      );
    });
  });

  group('CategoryService - updateCategory', () {
    test('updates category successfully', () async {
      when(
        () => apiClient.patch(
          ApiEndpoints.updateCategoryUrl('c1'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: updateCategoryResponse));

      final result = await service.updateCategory(
        id: 'c1',
        name: 'Food Updated',
        icon: 'restaurant',
        color: '#111111',
        backgroundColor: '#EEEEEE',
        groupType: 0,
      );

      expect(result.id, 'c1');
      expect(result.name, 'Food Updated');
    });

    test('throws when backend returns error in 200 payload', () async {
      when(
        () => apiClient.patch(
          ApiEndpoints.updateCategoryUrl('c1'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 200, data: categoryUpdateErrorData));

      expect(
        () => service.updateCategory(
          id: 'c1',
          name: 'Food',
          icon: 'restaurant',
          color: '#111111',
          backgroundColor: '#EEEEEE',
          groupType: 0,
        ),
        throwsException,
      );
    });

    test('throws on non-200 status', () async {
      when(
        () => apiClient.patch(
          ApiEndpoints.updateCategoryUrl('c1'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async =>
          buildResponse(statusCode: 400, data: {'error': 'Invalid'}));

      expect(
        () => service.updateCategory(
          id: 'c1',
          name: 'Food',
          icon: 'restaurant',
          color: '#111111',
          backgroundColor: '#EEEEEE',
          groupType: 0,
        ),
        throwsException,
      );
    });
  });

  group('CategoryService - deleteCategory', () {
    test('deletes category and returns true on 200', () async {
      when(
        () => apiClient.delete(ApiEndpoints.deleteCategoryUrl('c1')),
      ).thenAnswer((_) async => buildResponse(statusCode: 200));

      final result = await service.deleteCategory('c1');

      expect(result, true);
      verify(() => apiClient.delete(ApiEndpoints.deleteCategoryUrl('c1')))
          .called(1);
    });

    test('returns true on 204 No Content', () async {
      when(
        () => apiClient.delete(ApiEndpoints.deleteCategoryUrl('c1')),
      ).thenAnswer((_) async => buildResponse(statusCode: 204));

      final result = await service.deleteCategory('c1');

      expect(result, true);
    });

    test('returns false on non-success status', () async {
      when(
        () => apiClient.delete(ApiEndpoints.deleteCategoryUrl('c1')),
      ).thenAnswer((_) async => buildResponse(statusCode: 404));

      final result = await service.deleteCategory('c1');

      expect(result, false);
    });

    test('throws on DioException', () async {
      when(
        () => apiClient.delete(ApiEndpoints.deleteCategoryUrl('c1')),
      ).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(
        () => service.deleteCategory('c1'),
        throwsException,
      );
    });
  });

  group('CategoryService - deleteCategories', () {
    test('deletes multiple categories and returns true on 200', () async {
      when(
        () => apiClient.delete(
          ApiEndpoints.deleteCategories,
          data: {'ids': ['c1', 'c2']},
        ),
      ).thenAnswer((_) async => buildResponse(statusCode: 200));

      final result = await service.deleteCategories(['c1', 'c2']);

      expect(result, true);
      verify(
        () => apiClient.delete(
          ApiEndpoints.deleteCategories,
          data: {'ids': ['c1', 'c2']},
        ),
      ).called(1);
    });

    test('returns true on 204 No Content', () async {
      when(
        () => apiClient.delete(
          ApiEndpoints.deleteCategories,
          data: {'ids': ['c1', 'c2']},
        ),
      ).thenAnswer((_) async => buildResponse(statusCode: 204));

      final result = await service.deleteCategories(['c1', 'c2']);

      expect(result, true);
    });

    test('deletes single category in list', () async {
      when(
        () => apiClient.delete(
          ApiEndpoints.deleteCategories,
          data: {'ids': ['c1']},
        ),
      ).thenAnswer((_) async => buildResponse(statusCode: 200));

      final result = await service.deleteCategories(['c1']);

      expect(result, true);
    });

    test('returns false on non-success status', () async {
      when(
        () => apiClient.delete(
          ApiEndpoints.deleteCategories,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => buildResponse(statusCode: 500));

      final result = await service.deleteCategories(['c1']);

      expect(result, false);
    });
  });

  group('CategoryService - Error Handling', () {
    test('handles cancel exception', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.categories,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(DioException(
        type: DioExceptionType.cancel,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(
        () => service.getCategoriesByGroupType(0),
        throwsException,
      );
    });

    test('handles other DioException types', () async {
      when(
        () => apiClient.get(
          ApiEndpoints.categories,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(DioException(
        type: DioExceptionType.unknown,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(
        () => service.getCategoriesByGroupType(0),
        throwsException,
      );
    });
  });
}
