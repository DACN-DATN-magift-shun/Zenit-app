import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/layout/base_layout.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_flash.dart';
import 'package:zenit/core/widgets/app_drawer.dart';
import 'package:zenit/core/widgets/custom_long_press_menu.dart';
import 'package:zenit/features/setting_childs/category_manage/forms/add_edit_category_form.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';
import 'package:zenit/features/setting_childs/category_manage/widgets/group_category.dart';
import 'package:zenit/features/setting_childs/category_manage/widgets/single_category.dart';

class CategoryManageScreen extends StatefulWidget {
  const CategoryManageScreen({super.key});
  @override
  State<CategoryManageScreen> createState() => _CategoryManageScreenState();
}

class _CategoryManageScreenState extends State<CategoryManageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // cái addpost này để tránh lỗi trong flutter, để load UI trước rồi mới chạy lệnh trong ngoặc.
      context.read<CategoryProvider>().loadAllCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BaseLayout(
      appBar: CommonAppBar(
        title: l10n.categoryManage,
        showReturnIcon: true,
        onBack: () {
          Navigator.pop(context);
        },
      ),
      child: Consumer<CategoryProvider>(
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
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

          return RefreshIndicator(
            onRefresh: () => categoryProvider.refreshCategories(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s),
              itemCount: categoryProvider.categoryGroups.length,
              itemBuilder: (context, index) {
                final groupType = categoryProvider.categoryGroups.keys
                    .elementAt(index);
                final group = categoryProvider.categoryGroups[groupType]!;
                final localizedGroupName = _getLocalizedGroupName(
                  context,
                  groupType,
                  group.name,
                );

                if (group.categories.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GroupCategory(
                    title: localizedGroupName,
                    titleChipColor: _getGroupChipColor(groupType),
                    chipIcon: _getGroupChipIcon(groupType),
                    onAdd: () => _showAddCategoryDrawer(
                      context,
                      groupType,
                      localizedGroupName,
                    ),
                    items: group.categories.map((category) {
                      return CustomLongPressMenu<String>(
                        items: [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Symbols.edit,
                                  color: Theme.of(context)
                                      .extension<AppColorExtension>()!
                                      .neutralTextPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.edit,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .extension<AppColorExtension>()!
                                            .neutralTextPrimary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Symbols.delete,
                                  color: Theme.of(
                                    context,
                                  ).extension<AppColorExtension>()!.errorIcon,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.delete,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .extension<AppColorExtension>()!
                                            .errorText,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        color: Theme.of(context).cardColor,
                        elevation: 4,
                        onSelected: (value) {
                          if (value == 'delete') {
                            _handleDeleteCategory(category, groupType);
                          } else if (value == 'edit') {
                            _showEditCategoryDrawer(
                              context,
                              groupType,
                              localizedGroupName,
                              category,
                            );
                          }
                        },
                        child: SingleCategory(
                          icon: _parseIcon(category.icon),
                          name: category.name,
                          iconColor: _parseColor(category.color),
                          backgroundColor: _parseColor(
                            category.backgroundColor,
                          ),
                        ),
                      );
                      // --------------------------------
                    }).toList(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // --- HÀM XỬ LÝ XÓA  ---
  Future<void> _handleDeleteCategory(dynamic category, int groupType) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.confirmAction),
        content: Text(context.l10n.deleteCategoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              context.l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      final categoryProvider = context.read<CategoryProvider>();

      final success = await categoryProvider.deleteCategory(
        category.id,
        groupType,
      );

      if (!mounted) return;

      if (success) {
        AppFlash.success(context, context.l10n.deleteCategorySuccess);
      } else {
        AppFlash.error(
          context,
          categoryProvider.errorMessage ?? context.l10n.deleteFailed,
        );
      }
    }
  }

  // --- CÁC HÀM HELPER KHÁC ---

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

  Color _getGroupChipColor(int groupType) {
    switch (groupType) {
      case 0:
        return Theme.of(context).extension<AppColorExtension>()!.successIcon;
      case 1:
        return Theme.of(context).extension<AppColorExtension>()!.primarySubtext;
      case 2:
        return Theme.of(context).extension<AppColorExtension>()!.infoIcon;
      case 3:
        return Theme.of(context).extension<AppColorExtension>()!.infoIcon;
      case 4:
        return Theme.of(context).extension<AppColorExtension>()!.secondaryHover;
      case 5:
        return Theme.of(context).extension<AppColorExtension>()!.primarySubtext;
      default:
        return Theme.of(context).extension<AppColorExtension>()!.primarySubtext;
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
      case 5:
        return Symbols.category;
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

  /// Parse color từ hex string để hiển thị
  /// Chỉ dùng để đọc màu từ server, không cho phép user chỉnh sửa
  Color? _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return null;
    try {
      String hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return null;
    }
  }

  void _showEditCategoryDrawer(
    BuildContext context,
    int groupType,
    String groupName,
    CategoryModel category,
  ) {
    AppDrawer.showAsBottomSheet(
      context: context,
      title: context.l10n.editCategory,
      showDragHandle: true,
      height: MediaQuery.of(context).size.height * 0.85,
      body: AddCategoryForm(
        groupType: groupType,
        groupName: groupName,
        initialName: category.name,
        initialIcon: category.icon,
        initialExpenseLimit: category.expenseLimit,
        isEditMode: true,
        onSubmit: (data) async {
          print('=== Edit Category Submit ===');
          print('No color data sent in edit mode');

          final categoryProvider = context.read<CategoryProvider>();

          final success = await categoryProvider.updateCategory(
            id: category.id,
            name: data.name,
            icon: data.icon,
            color: category.color, // Giữ màu cũ
            backgroundColor: category.backgroundColor, // Giữ màu cũ
            groupType: data.groupType,
            expenseLimit: data.expenseLimit ?? 0,
            expenseAlertThreshold: category.expenseAlertThreshold,
            oldGroupType: groupType != data.groupType ? groupType : null,
          );

          if (context.mounted) {
            Navigator.pop(context);
            if (success) {
              AppFlash.success(
                context,
                context.l10n.categoryUpdatedSuccess(data.name),
              );
            } else {
              AppFlash.error(
                context,
                categoryProvider.errorMessage ??
                    context.l10n.categoryUpdateFailed,
              );
            }
          }
        },
      ),
    );
  }

  void _showAddCategoryDrawer(
    BuildContext context,
    int groupType,
    String groupName,
  ) {
    AppDrawer.showAsBottomSheet(
      context: context,
      title: context.l10n.addCategory,
      showDragHandle: true,
      height: MediaQuery.of(context).size.height * 0.85,
      body: AddCategoryForm(
        groupType: groupType,
        groupName: groupName,
        isEditMode: false,
        onSubmit: (data) async {
          final categoryProvider = context.read<CategoryProvider>();

          print('=== Add Category with Random Colors ===');
          print('Icon Color: ${data.color}');
          print('Background Color: ${data.backgroundColor}');

          final success = await categoryProvider.addCategory(
            name: data.name,
            icon: data.icon,
            color: data.color!,
            backgroundColor: data.backgroundColor!,
            groupType: data.groupType,
            expenseLimit: data.expenseLimit ?? 0,
            expenseAlertThreshold: 0,
          );

          if (context.mounted) {
            Navigator.pop(context);
            if (success) {
              AppFlash.success(
                context,
                context.l10n.categoryAddedSuccess(data.name),
              );
            } else {
              AppFlash.error(
                context,
                categoryProvider.errorMessage ?? context.l10n.categoryAddFailed,
              );
            }
          }
        },
      ),
    );
  }
}
