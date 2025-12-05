import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/services/navigation_service.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';

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
    // Load categories nếu chưa có
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
    if (_searchQuery.isEmpty) return categories;
    return categories
        .where((cat) => cat.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.xl),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.l),
              
              Row(
                children: [
                  // Search 
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.secondaryMain,
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search for a tag',
                          hintStyle: TextStyle(color: colors.neutralTextDisable),
                          prefixIcon: Icon(
                            Symbols.search_rounded,
                            color: colors.neutralTextSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.l,
                            vertical: AppSizes.m,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.m),
                  
                  // Tag Manage
                  TextButton.icon(
                    onPressed: () {
                      // Navigate to tag manage screen
                      NavigationService.instance.navigateTo('/settings/category_manage');
                    },
                    icon: Icon(
                      Symbols.add_rounded,
                      color: colors.primaryMain,
                    ),
                    label: Text(
                      'Tag manage',
                      style: TextStyle(
                        color: colors.primaryMain,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),

              // Category Groups
              ...categoryProvider.categoryGroups.entries.map((entry) {
                final groupType = entry.key;
                final group = entry.value;
                final filteredCategories = _filterCategories(group.categories);

                if (filteredCategories.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.l),
                  child: _buildCategoryGroup(
                    context,
                    title: group.name,
                    categories: filteredCategories,
                    chipColor: _getGroupChipColor(groupType, colors),
                    chipIcon: _getGroupChipIcon(groupType),
                  ),
                );
              }),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryGroup(
    BuildContext context, {
    required String title,
    required List<CategoryModel> categories,
    required Color chipColor,
    required IconData chipIcon,
  }) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return Container(
      padding: const EdgeInsets.all(AppSizes.l),
      decoration: BoxDecoration(
        color: colors.neutralBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: colors.neutralBorder.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Title Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: chipColor,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  chipIcon,
                  size: AppSizes.textXL,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.l),

          // Category Items Grid
          Wrap(
            spacing: AppSizes.l,
            runSpacing: AppSizes.m,
            children: categories.map((category) {
              final isSelected = widget.selectedCategory?.id == category.id;
              return _buildCategoryItem(context, category, isSelected);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryModel category, bool isSelected) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final bgColor = _parseColor(category.backgroundColor);
    final iconColor = _parseColor(category.color);

    return InkWell(
      onTap: () => widget.onCategorySelected(category),
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.s),
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: colors.primaryMain, width: 2)
              : null,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall),
        ),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.s),
            child: Icon(
              _parseIcon(category.icon),
              fill: 1.0,
              weight: 400,
              grade: 0.25,
              color: iconColor,
              size: AppSizes.textXXXL,
            ),
          ),
        ),
      ),
    );
  }

  Color _getGroupChipColor(int groupType, AppColorExtension colors) {
    switch (groupType) {
      case 0:
        return colors.successIcon;
      case 1:
        return colors.primaryMain;
      case 2:
        return colors.warningIcon;
      case 3:
        return colors.errorIcon;
      case 4:
        return colors.infoIcon;
      default:
        return colors.neutralTextSecondary;
    }
  }

  IconData _getGroupChipIcon(int groupType) {
    switch (groupType) {
      case 0:
        return Symbols.receipt_long_rounded;
      case 1:
        return Symbols.payments_rounded;
      case 2:
        return Symbols.savings_rounded;
      case 3:
        return Symbols.account_balance_rounded;
      case 4:
        return Symbols.category_rounded;
      default:
        return Symbols.category_rounded;
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
