import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';

final categoryWidgetNecessaryFood = CategoryModel(
  id: 'c1',
  name: 'Food',
  icon: 'restaurant',
  color: '#111111',
  backgroundColor: '#EEEEEE',
  groupType: '0',
);

final categoryWidgetIncomeSalary = CategoryModel(
  id: 'c2',
  name: 'Salary',
  icon: 'attach_money',
  color: '#222222',
  backgroundColor: '#DDDDDD',
  groupType: '5',
);

Map<int, CategoryGroup> buildCategoryWidgetGroups() {
  return <int, CategoryGroup>{
    0: CategoryGroup(
      name: 'Necessary',
      type: 0,
      categories: <CategoryModel>[categoryWidgetNecessaryFood],
    ),
    5: CategoryGroup(
      name: 'Income',
      type: 5,
      categories: <CategoryModel>[categoryWidgetIncomeSalary],
    ),
  };
}

Map<int, CategoryGroup> buildCategoryWidgetMissingIncomeGroups() {
  return <int, CategoryGroup>{
    0: CategoryGroup(
      name: 'Necessary',
      type: 0,
      categories: <CategoryModel>[categoryWidgetNecessaryFood],
    ),
  };
}