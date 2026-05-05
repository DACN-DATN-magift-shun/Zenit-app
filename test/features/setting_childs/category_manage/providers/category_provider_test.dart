import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';
import 'package:zenit/features/setting_childs/category_manage/services/category_service.dart';

import '../../../../mocks/features/setting_childs/category_manage/category_provider_mock_data.dart';

class MockCategoryService extends Mock implements CategoryService {}

void main() {
  late MockCategoryService service;
  late CategoryProvider provider;

  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    service = MockCategoryService();
    provider = CategoryProvider(categoryService: service);
  });

  group('CategoryProvider', () {
    test('loadAllCategories success populates state', () async {
      when(
        () => service.getAllCategoriesByAllGroups(),
      ).thenAnswer((_) async => buildCategoryProviderAllGroups());

      await provider.loadAllCategories();

      expect(provider.errorMessage, isNull);
      expect(provider.hasData, true);
      expect(provider.totalCategories, 2);
      expect(provider.getCategoriesByGroupType(0).length, 1);
      expect(provider.getCategoryGroup(1)?.name, 'Assets');
    });

    test('loadAllCategories failure normalizes error message', () async {
      when(() => service.getAllCategoriesByAllGroups()).thenThrow(
        Exception('boom'),
      );

      await provider.loadAllCategories();

      expect(provider.errorMessage, 'boom');
      expect(provider.isLoading, false);
    });

    test('addCategory success appends to local group', () async {
      when(
        () => service.getAllCategoriesByAllGroups(),
      ).thenAnswer((_) async => buildCategoryProviderAllGroups());
      await provider.loadAllCategories();

      when(
        () => service.createCategory(
          name: 'Transport',
          icon: 'directions_car',
          color: '#333333',
          backgroundColor: '#CCCCCC',
          groupType: 0,
          expenseLimit: 0,
          expenseAlertThreshold: 0,
        ),
      ).thenAnswer((_) async => categoryProviderNewCategory);

      final result = await provider.addCategory(
        name: 'Transport',
        icon: 'directions_car',
        color: '#333333',
        backgroundColor: '#CCCCCC',
        groupType: 0,
      );

      expect(result, true);
      expect(provider.getCategoriesByGroupType(0).length, 2);
      expect(provider.errorMessage, isNull);
    });

    test('addCategory returns false when created category id is empty', () async {
      when(
        () => service.createCategory(
          name: 'Invalid',
          icon: 'help',
          color: '#000000',
          backgroundColor: '#FFFFFF',
          groupType: 0,
          expenseLimit: 0,
          expenseAlertThreshold: 0,
        ),
      ).thenAnswer((_) async => categoryProviderInvalidCreatedCategory);

      final result = await provider.addCategory(
        name: 'Invalid',
        icon: 'help',
        color: '#000000',
        backgroundColor: '#FFFFFF',
        groupType: 0,
      );

      expect(result, false);
      expect(provider.errorMessage, 'Failed to create category: Invalid response');
    });

    test('updateCategory preserves old color when API returns empty color', () async {
      when(
        () => service.getAllCategoriesByAllGroups(),
      ).thenAnswer((_) async => buildCategoryProviderAllGroups());
      await provider.loadAllCategories();

      when(
        () => service.updateCategory(
          id: 'c1',
          name: 'Food Updated',
          icon: 'restaurant',
          color: '#aaaaaa',
          backgroundColor: '#bbbbbb',
          groupType: 0,
          expenseLimit: 0,
          expenseAlertThreshold: 0,
        ),
      ).thenAnswer((_) async => categoryProviderUpdatedCategoryWithoutColor);

      final result = await provider.updateCategory(
        id: 'c1',
        name: 'Food Updated',
        icon: 'restaurant',
        color: '#aaaaaa',
        backgroundColor: '#bbbbbb',
        groupType: 0,
      );

      final updated = provider.findCategoryById('c1');
      expect(result, true);
      expect(updated?.name, 'Food Updated');
      expect(updated?.color, '#111111');
      expect(updated?.backgroundColor, '#EEEEEE');
    });

    test('updateCategory moves category to new group when oldGroupType is provided', () async {
      when(
        () => service.getAllCategoriesByAllGroups(),
      ).thenAnswer((_) async => buildCategoryProviderAllGroups());
      await provider.loadAllCategories();

      when(
        () => service.updateCategory(
          id: 'c1',
          name: 'Food Moved',
          icon: 'restaurant',
          color: '#444444',
          backgroundColor: '#BBBBBB',
          groupType: 1,
          expenseLimit: 0,
          expenseAlertThreshold: 0,
        ),
      ).thenAnswer((_) async => categoryProviderMovedCategory);

      final result = await provider.updateCategory(
        id: 'c1',
        name: 'Food Moved',
        icon: 'restaurant',
        color: '#444444',
        backgroundColor: '#BBBBBB',
        groupType: 1,
        oldGroupType: 0,
      );

      expect(result, true);
      expect(provider.getCategoriesByGroupType(0).any((c) => c.id == 'c1'), false);
      expect(provider.getCategoriesByGroupType(1).any((c) => c.id == 'c1'), true);
    });

    test('deleteCategory success removes item from local state', () async {
      when(
        () => service.getAllCategoriesByAllGroups(),
      ).thenAnswer((_) async => buildCategoryProviderAllGroups());
      await provider.loadAllCategories();

      when(() => service.deleteCategory('c1')).thenAnswer((_) async => true);

      final result = await provider.deleteCategory('c1', 0);

      expect(result, true);
      expect(provider.getCategoriesByGroupType(0).any((c) => c.id == 'c1'), false);
    });

    test('deleteCategoriesFromMultipleGroups removes items from each group', () async {
      when(
        () => service.getAllCategoriesByAllGroups(),
      ).thenAnswer((_) async => buildCategoryProviderAllGroups());
      await provider.loadAllCategories();

      when(() => service.deleteCategories(any())).thenAnswer((_) async => true);

      final result = await provider.deleteCategoriesFromMultipleGroups({
        0: ['c1'],
        1: ['c2'],
      });

      expect(result, true);
      expect(provider.totalCategories, 0);
    });

    test('clearError and reset reset provider state', () async {
      when(() => service.getAllCategoriesByAllGroups()).thenThrow(Exception('oops'));
      await provider.loadAllCategories();
      expect(provider.errorMessage, 'oops');

      provider.clearError();
      expect(provider.errorMessage, isNull);

      provider.reset();
      expect(provider.hasData, false);
      expect(provider.isLoading, false);
      expect(provider.isActionLoading, false);
      expect(provider.errorMessage, isNull);
    });
  });
}
