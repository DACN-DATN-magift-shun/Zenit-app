import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import '../../../../mocks/features/setting_childs/category_manage/category_model_mock_data.dart';
import '../../../../mocks/json_source_mock.dart';

void main() {
  group('CategoryModel', () {
    test('fromJson parses doubles, dates and defaults', () {
      final source = MockJsonSource();
      when(() => source.value).thenReturn(categoryFromJsonMockData);

      final model = CategoryModel.fromJson(source.value);

      expect(model.id, 'c1');
      expect(model.expenseLimit, 1000.5);
      expect(model.expenseAlertThreshold, 80.0);
      expect(model.groupType, '0');
      expect(model.createdAt, DateTime.parse('2026-04-20T00:00:00Z'));
    });

    test('toJsonWithId includes id and patch fields', () {
      final model = CategoryModel(
        id: 'c2',
        name: 'Transport',
        icon: 'car',
        groupType: '1',
      );

      final json = model.toJsonWithId();

      expect(json['id'], 'c2');
      expect(json['name'], 'Transport');
      expect(json['groupType'], '1');
    });

    test('CategoryGroup.fromJson parses category list and type', () {
      final source = MockJsonSource();
      when(() => source.value).thenReturn(categoryGroupFromJsonMockData);

      final group = CategoryGroup.fromJson(source.value);

      expect(group.name, 'Necessary');
      expect(group.type, 2);
      expect(group.categories.length, 1);
    });

    test('GroupType.fromValue falls back to necessary', () {
      expect(GroupType.fromValue(4), GroupType.giving);
      expect(GroupType.fromValue(999), GroupType.necessary);
    });
  });
}
