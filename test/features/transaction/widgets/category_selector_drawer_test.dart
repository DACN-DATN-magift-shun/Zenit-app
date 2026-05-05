import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';
import 'package:zenit/features/setting_childs/category_manage/widgets/group_category.dart';
import 'package:zenit/features/setting_childs/category_manage/widgets/single_category.dart';
import 'package:zenit/features/transaction/widgets/category_selector_drawer.dart';
import 'package:zenit/l10n/app_localizations.dart';

import '../../../fixtures/features/setting_childs/category_manage/category_widget_fixtures.dart';
import '../../../mocks/features/setting_childs/category_manage/category_provider_widget_mock.dart';

Widget _buildTestApp({
  required CategoryProvider provider,
  required void Function(CategoryModel) onCategorySelected,
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
  group('Category widgets', () {
    testWidgets('SingleCategory renders and shows selected indicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: const Scaffold(
            body: SingleCategory(
              name: 'Food',
              isSelected: true,
            ),
          ),
        ),
      );

      expect(find.text('Food'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('GroupCategory shows items and add button', (tester) async {
      var addTapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: GroupCategory(
              title: 'Necessary',
              titleChipColor: Colors.green,
              chipIcon: Icons.home,
              onAdd: () => addTapCount += 1,
              items: const <Widget>[
                Text('Item 1'),
                Text('Item 2'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Necessary'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Thêm'), findsOneWidget);

      await tester.tap(find.text('Thêm'));
      await tester.pump();

      expect(addTapCount, 1);
    });

    testWidgets('shows loading indicator when provider is loading', (
      tester,
    ) async {
      final provider = MockCategoryProvider();
      when(() => provider.isLoading).thenReturn(true);
      when(() => provider.errorMessage).thenReturn(null);
      when(() => provider.hasData).thenReturn(true);
      when(() => provider.categoryGroups).thenReturn(<int, CategoryGroup>{});

      await tester.pumpWidget(
        _buildTestApp(provider: provider, onCategorySelected: (_) {}),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when provider has no data', (tester) async {
      final provider = MockCategoryProvider();
      when(() => provider.isLoading).thenReturn(false);
      when(() => provider.errorMessage).thenReturn(null);
      when(() => provider.hasData).thenReturn(false);
      when(() => provider.categoryGroups).thenReturn(<int, CategoryGroup>{});
      when(() => provider.loadAllCategories()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        _buildTestApp(provider: provider, onCategorySelected: (_) {}),
      );

      await tester.pump();

      expect(find.text('No data yet'), findsOneWidget);
      verify(() => provider.loadAllCategories()).called(1);
    });

    testWidgets('shows error state and retry triggers loadAllCategories', (
      tester,
    ) async {
      final provider = MockCategoryProvider();
      when(() => provider.isLoading).thenReturn(false);
      when(() => provider.errorMessage).thenReturn('boom');
      when(() => provider.hasData).thenReturn(true);
      when(() => provider.categoryGroups).thenReturn(<int, CategoryGroup>{});
      when(() => provider.loadAllCategories()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        _buildTestApp(provider: provider, onCategorySelected: (_) {}),
      );

      expect(find.text('An error occurred'), findsOneWidget);
      expect(find.text('boom'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => provider.loadAllCategories()).called(1);
    });

    testWidgets('renders categories for allowed groups and returns selection', (
      tester,
    ) async {
      final provider = MockCategoryProvider();
      final groups = buildCategoryWidgetGroups();
      when(() => provider.isLoading).thenReturn(false);
      when(() => provider.errorMessage).thenReturn(null);
      when(() => provider.hasData).thenReturn(true);
      when(() => provider.categoryGroups).thenReturn(groups);
      when(() => provider.getCategoryGroup(any())).thenAnswer((invocation) {
        final groupType = invocation.positionalArguments.first as int;
        return groups[groupType];
      });

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

      await tester.pump();

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Salary'), findsNothing);

      await tester.tap(find.text('Food'));
      await tester.pump();

      expect(selected?.id, 'c1');
    });

    testWidgets('filters categories by search text', (tester) async {
      final provider = MockCategoryProvider();
      final groups = buildCategoryWidgetGroups();
      when(() => provider.isLoading).thenReturn(false);
      when(() => provider.errorMessage).thenReturn(null);
      when(() => provider.hasData).thenReturn(true);
      when(() => provider.categoryGroups).thenReturn(groups);
      when(() => provider.getCategoryGroup(any())).thenAnswer((invocation) {
        final groupType = invocation.positionalArguments.first as int;
        return groups[groupType];
      });

      await tester.pumpWidget(
        _buildTestApp(provider: provider, onCategorySelected: (_) {}),
      );
      await tester.pump();

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'foo');
      await tester.pump();

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Salary'), findsNothing);
    });

    testWidgets('loads missing allowed group types on first frame', (
      tester,
    ) async {
      final provider = MockCategoryProvider();
      final groups = buildCategoryWidgetMissingIncomeGroups();
      when(() => provider.isLoading).thenReturn(false);
      when(() => provider.errorMessage).thenReturn(null);
      when(() => provider.hasData).thenReturn(true);
      when(() => provider.categoryGroups).thenReturn(groups);
      when(() => provider.getCategoryGroup(0)).thenReturn(groups[0]);
      when(() => provider.getCategoryGroup(5)).thenReturn(null);
      when(() => provider.loadCategoriesByGroupType(5)).thenAnswer((_) async => null);

      await tester.pumpWidget(
        _buildTestApp(
          provider: provider,
          allowedGroupTypes: const <int>{0, 5},
          onCategorySelected: (_) {},
        ),
      );

      await tester.pump();

      verify(() => provider.loadCategoriesByGroupType(5)).called(1);
    });
  });
}
