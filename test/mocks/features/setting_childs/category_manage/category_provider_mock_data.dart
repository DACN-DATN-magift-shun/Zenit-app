import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';

Map<int, CategoryGroup> buildCategoryProviderAllGroups() {
  final categoryProviderGroup0 = CategoryGroup(
    name: 'Necessary',
    type: 0,
    categories: [
      CategoryModel(
        id: 'c1',
        name: 'Food',
        icon: 'restaurant',
        color: '#111111',
        backgroundColor: '#EEEEEE',
        groupType: '0',
      ),
    ],
  );

  final categoryProviderGroup1 = CategoryGroup(
    name: 'Assets',
    type: 1,
    categories: [
      CategoryModel(
        id: 'c2',
        name: 'Investment',
        icon: 'trending_up',
        color: '#222222',
        backgroundColor: '#DDDDDD',
        groupType: '1',
      ),
    ],
  );

  return <int, CategoryGroup>{
    0: categoryProviderGroup0,
    1: categoryProviderGroup1,
  };
}

final categoryProviderNewCategory = CategoryModel(
  id: 'c3',
  name: 'Transport',
  icon: 'directions_car',
  color: '#333333',
  backgroundColor: '#CCCCCC',
  groupType: '0',
);

final categoryProviderInvalidCreatedCategory = CategoryModel(
  id: '',
  name: 'Invalid',
  icon: 'help',
  color: '#000000',
  backgroundColor: '#FFFFFF',
  groupType: '0',
);

final categoryProviderUpdatedCategoryWithoutColor = CategoryModel(
  id: 'c1',
  name: 'Food Updated',
  icon: 'restaurant',
  color: '',
  backgroundColor: '',
  groupType: '0',
);

final categoryProviderMovedCategory = CategoryModel(
  id: 'c1',
  name: 'Food Moved',
  icon: 'restaurant',
  color: '#444444',
  backgroundColor: '#BBBBBB',
  groupType: '1',
);
