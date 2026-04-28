import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/setting_childs/category_manage/services/category_service.dart';

import '../../../../mocks/features/setting_childs/category_manage/services/category_service_mock_data.dart';
import '../../../../mocks/network/api_client_mocks.dart';

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

  test('getCategoriesByGroupType handles list payload', () async {
    when(
      () => apiClient.get(ApiEndpoints.categories, queryParameters: {'groupType': 0,'Page': 1,
        'PageSize': 10}),
    ).thenAnswer((_) async => buildResponse(statusCode: 200, data: categoryListAsListData));

    final result = await service.getCategoriesByGroupType(0);

    expect(result.type, 0);
    expect(result.categories.length, 1);
    expect(result.categories.first.id, 'c1');
  });

  test('updateCategory throws when backend returns error in 200 payload', () async {
    when(
      () => apiClient.patch(ApiEndpoints.updateCategoryUrl('c1'), data: any(named: 'data')),
    ).thenAnswer((_) async => buildResponse(statusCode: 200, data: categoryUpdateErrorData));

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

  test('deleteCategories posts ids and returns true on 204', () async {
    when(
      () => apiClient.delete(ApiEndpoints.deleteCategories, data: {'ids': ['c1', 'c2']}),
    ).thenAnswer((_) async => buildResponse(statusCode: 204));

    final result = await service.deleteCategories(['c1', 'c2']);

    expect(result, true);
  });
}
