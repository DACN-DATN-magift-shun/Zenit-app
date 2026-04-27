import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';
import 'package:zenit/features/transaction/widgets/category_selector_drawer.dart';
import 'package:zenit/l10n/app_localizations.dart';

class TestCategoryProvider extends CategoryProvider {
  TestCategoryProvider({
    required this.isLoadingValue,
    required this.errorMessageValue,
    required this.groups,
    required this.hasDataValue,
  }) : super(categoryService: null);

  bool isLoadingValue;
  String? errorMessageValue;
  bool hasDataValue;
  Map<int, CategoryGroup> groups;

  int loadAllCategoriesCallCount = 0;
  final List<int> loadCategoriesByGroupTypeCalls = <int>[];

  @override
  bool get isLoading => isLoadingValue;

  @override
  String? get errorMessage => errorMessageValue;

  @override
  bool get hasData => hasDataValue;

  @override
  Map<int, CategoryGroup> get categoryGroups => groups;

  @override
  CategoryGroup? getCategoryGroup(int groupType) => groups[groupType];

  @override
  Future<void> loadAllCategories() async {
    loadAllCategoriesCallCount += 1;
  }

  @override
  Future<void> loadCategoriesByGroupType(int groupType) async {
    loadCategoriesByGroupTypeCalls.add(groupType);
  }
}

CategoryModel _category({
  required String id,
  required String name,
  required String groupType,
}) {
  return CategoryModel(
    id: id,
    name: name,
    icon: 'restaurant_rounded',
    color: '#111111',
    backgroundColor: '#EEEEEE',
    groupType: groupType,
  );
}

Widget _buildTestApp({
  required TestCategoryProvider provider,
  required Function(CategoryModel) onCategorySelected,
  Set<int>? allowedGroupTypes,
  CategoryModel? selectedCategory,
}) {
  return ChangeNotifierProvider<CategoryProvider>.value(
    value: provider,
    child: MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: CategorySelectorDrawer(
          selectedCategory: selectedCategory,
          onCategorySelected: onCategorySelected,
          allowedGroupTypes: allowedGroupTypes,
        ),
      ),
    ),
  );
}

void main() {
  group('CategorySelectorDrawer', () {
    testWidgets('shows loading indicator when provider is loading', (
      tester,
    ) async {
      final provider = TestCategoryProvider(
        isLoadingValue: true,
        errorMessageValue: null,
        groups: <int, CategoryGroup>{},
        hasDataValue: true,
      );

      await tester.pumpWidget(
        _buildTestApp(provider: provider, onCategorySelected: (_) {}),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when provider has no data', (tester) async {
      final provider = TestCategoryProvider(
        isLoadingValue: false,
        errorMessageValue: null,
        groups: <int, CategoryGroup>{},
        hasDataValue: false,
      );

      await tester.pumpWidget(
        _buildTestApp(provider: provider, onCategorySelected: (_) {}),
      );

      expect(find.text('No data yet'), findsOneWidget);
    });

    testWidgets('calls loadAllCategories on first frame when provider has no data', (
      tester,
    ) async {
      final provider = TestCategoryProvider(
        isLoadingValue: false,
        errorMessageValue: null,
        groups: <int, CategoryGroup>{},
        hasDataValue: false,
      );

      await tester.pumpWidget(
        _buildTestApp(provider: provider, onCategorySelected: (_) {}),
      );
      await tester.pump();

      expect(provider.loadAllCategoriesCallCount, 1);
    });

    testWidgets('shows error state and retry triggers loadAllCategories', (
      tester,
    ) async {
      final provider = TestCategoryProvider(
        isLoadingValue: false,
        errorMessageValue: 'boom',
        groups: <int, CategoryGroup>{},
        hasDataValue: true,
      );

      await tester.pumpWidget(
        _buildTestApp(provider: provider, onCategorySelected: (_) {}),
      );

      expect(find.text('An error occurred'), findsOneWidget);
      expect(find.text('boom'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(provider.loadAllCategoriesCallCount, 1);
    });

    testWidgets('renders categories for allowed groups and returns selected category on tap', (
      tester,
    ) async {
      final food = _category(id: 'c1', name: 'Food', groupType: '0');
      final salary = _category(id: 'c2', name: 'Salary', groupType: '5');

      final provider = TestCategoryProvider(
        isLoadingValue: false,
        errorMessageValue: null,
        hasDataValue: true,
        groups: <int, CategoryGroup>{
          0: CategoryGroup(name: 'Necessary', type: 0, categories: <CategoryModel>[food]),
          5: CategoryGroup(name: 'Income', type: 5, categories: <CategoryModel>[salary]),
        },
      );

      CategoryModel? selected;

      await tester.pumpWidget(
        _buildTestApp(
          provider: provider,
          allowedGroupTypes: const <int>{0},
          onCategorySelected: (category) {
            selected = category;
          },
        ),
      );

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Salary'), findsNothing);

      await tester.tap(find.text('Food'));
      await tester.pump();

      expect(selected?.id, 'c1');
    });

    testWidgets('filters categories by search text', (tester) async {
      final food = _category(id: 'c1', name: 'Food', groupType: '0');
      final transport = _category(id: 'c2', name: 'Transport', groupType: '0');

      final provider = TestCategoryProvider(
        isLoadingValue: false,
        errorMessageValue: null,
        hasDataValue: true,
        groups: <int, CategoryGroup>{
          0: CategoryGroup(
            name: 'Necessary',
            type: 0,
            categories: <CategoryModel>[food, transport],
          ),
        },
      );

      await tester.pumpWidget(
        _buildTestApp(provider: provider, onCategorySelected: (_) {}),
      );

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'foo');
      await tester.pump();

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsNothing);
    });
  });
}
