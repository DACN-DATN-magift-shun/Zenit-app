import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';
import 'package:zenit/features/setting_childs/category_manage/widgets/group_category.dart';
import 'package:zenit/features/setting_childs/category_manage/widgets/single_category.dart';

class CategorySelectorDrawer extends StatefulWidget {
  final CategoryModel? selectedCategory;
  final Function(CategoryModel) onCategorySelected;

  const CategorySelectorDrawer({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategorySelectorDrawer> createState() => _CategorySelectorDrawerState();
}

class _CategorySelectorDrawerState extends State<CategorySelectorDrawer> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = context.read<CategoryProvider>();
      if (!categoryProvider.hasData) {
        categoryProvider.loadAllCategories();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryModel> _filterCategories(List<CategoryModel> categories) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return categories;
    }

    return categories.where((item) {
      return item.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (categoryProvider.errorMessage != null) {
          return Center(
            child: Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.l),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Symbols.error_rounded,
                      size: 28,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.errorOccurred,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      categoryProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonalIcon(
                      onPressed: () => categoryProvider.loadAllCategories(),
                      icon: const Icon(Symbols.refresh_rounded),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!categoryProvider.hasData) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Symbols.category_rounded,
                  size: 32,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.noData,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        final groups = categoryProvider.categoryGroups.entries.toList();

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s),
          children: [
            const SizedBox(height: AppSizes.s),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: l10n.searchForTag,
                prefixIcon: const Icon(Symbols.search_rounded),
                suffixIcon: _searchQuery.trim().isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(Symbols.close_rounded),
                      ),
                filled: true,
                fillColor: const Color(0xFFEBE4F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.l,
                  vertical: AppSizes.m,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.l),
            ...groups.map((entry) {
              final groupType = entry.key;
              final group = entry.value;
              final categories = _filterCategories(group.categories);

              if (categories.isEmpty) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GroupCategory(
                  title: _getLocalizedGroupName(context, groupType, group.name),
                  titleChipColor: _getGroupChipColor(context, groupType),
                  chipIcon: _getGroupChipIcon(groupType),
                  showAddButton: false,
                  items: categories.map((category) {
                    final isSelected =
                        widget.selectedCategory?.id == category.id;

                    return InkWell(
                      onTap: () => widget.onCategorySelected(category),
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadiusXSmall,
                      ),
                      child: SingleCategory(
                        icon: _parseIcon(category.icon),
                        name: category.name,
                        iconColor: _parseColor(category.color),
                        backgroundColor: _parseColor(category.backgroundColor),
                        isSelected: isSelected,
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  String _getLocalizedGroupName(
    BuildContext context,
    int groupType,
    String fallbackName,
  ) {
    final l10n = context.l10n;
    switch (groupType) {
      case 0:
        return l10n.groupNecessary;
      case 1:
        return l10n.groupSavings;
      case 2:
        return l10n.groupSelfDevelopment;
      case 3:
        return l10n.groupEntertainment;
      case 4:
        return l10n.groupGiving;
      default:
        return fallbackName;
    }
  }

  Color _getGroupChipColor(BuildContext context, int groupType) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    switch (groupType) {
      case 0:
        return colors.successIcon;
      case 1:
        return colors.primarySubtext;
      case 2:
        return colors.infoIcon;
      case 3:
        return colors.infoIcon;
      case 4:
        return colors.secondaryHover;
      default:
        return colors.neutralTextSecondary;
    }
  }

  IconData _getGroupChipIcon(int groupType) {
    switch (groupType) {
      case 0:
        return Symbols.home_filled;
      case 1:
        return Symbols.shopping_bag_rounded;
      case 2:
        return Symbols.attach_money_rounded;
      case 3:
        return Symbols.savings;
      case 4:
        return Symbols.trending_up;
      default:
        return Symbols.category;
    }
  }

  IconData _parseIcon(String iconName) {
    final iconMap = <String, IconData>{
      'home': Symbols.home,
      'shopping_cart': Symbols.shopping_cart,
      'restaurant': Symbols.restaurant,
      'directions_car': Symbols.directions_car,
      'local_hospital': Symbols.local_hospital,
      'school': Symbols.school,
      'work': Symbols.work,
      'attach_money': Symbols.attach_money,
      'savings': Symbols.savings,
      'trending_up': Symbols.trending_up,
      // Single category icons
      'shopping_cart_rounded': Symbols.shopping_cart_rounded,
      'restaurant_rounded': Symbols.restaurant_rounded,
      'account_balance_rounded': Symbols.account_balance_rounded,
      'trending_up_rounded': Symbols.trending_up_rounded,
      'school_rounded': Symbols.school_rounded,
      'menu_book_rounded': Symbols.menu_book_rounded,
      'movie_rounded': Symbols.movie_rounded,
      'fitness_center_rounded': Symbols.fitness_center_rounded,
    };

    return iconMap[iconName] ?? Symbols.category;
  }

  Color _parseColor(String hexColor) {
    try {
      String hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}
