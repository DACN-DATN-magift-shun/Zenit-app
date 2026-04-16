import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/layout/base_layout.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_confirm_dialog.dart';
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

          // Chỉ hiển thị lỗi toàn màn hình khi load thất bại và không có dữ liệu.
          // Lỗi từ các thao tác CRUD (update/add/delete) sẽ hiển thị bằng flash.
          if (categoryProvider.errorMessage != null && !categoryProvider.hasData) {
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
              padding: EdgeInsets.fromLTRB(
                AppSizes.s,
                0,
                AppSizes.s,
                AppSizes.xl + MediaQuery.of(context).padding.bottom,
              ),
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
    final confirm = await AppConfirmDialog.show(
      context: context,
      title: context.l10n.confirmAction,
      message: context.l10n.deleteCategoryConfirm,
      confirmText: context.l10n.delete,
      isDestructive: true,
    );

    if (confirm) {
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
          _localizeCategoryErrorMessage(
            context,
            categoryProvider.errorMessage,
            context.l10n.deleteFailed,
          ),
        );
      }
    }
  }

  // --- CÁC HÀM HELPER KHÁC ---

  String _localizeCategoryErrorMessage(
    BuildContext context,
    String? raw,
    String fallback,
  ) {
    if (raw == null || raw.trim().isEmpty) {
      return fallback;
    }

    final isVi = Localizations.localeOf(context).languageCode.toLowerCase() ==
        'vi';
    final normalized = raw.toLowerCase();

    if (normalized.contains('cannot update default category name or icon')) {
      return isVi
          ? 'Không thể sửa tên hoặc biểu tượng của danh mục mặc định.'
          : 'Cannot update the name or icon of a default category.';
    }

    if (normalized.contains('internal server error')) {
      return isVi
          ? 'Hệ thống đang gặp sự cố. Vui lòng thử lại sau.'
          : 'The server is having issues. Please try again later.';
    }

    return raw;
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
        return 'Assets';
      case 2:
        return l10n.groupSelfDevelopment;
      case 3:
        return l10n.groupEntertainment;
      case 4:
        return l10n.groupGiving;
      case 5:
        return Localizations.localeOf(context).languageCode.toLowerCase() ==
                'vi'
            ? 'Thu nhập'
            : 'Income';
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
        return Symbols.account_balance_wallet_rounded;
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
            if (success) {
              Navigator.pop(context);
              AppFlash.success(
                context,
                context.l10n.categoryUpdatedSuccess(data.name),
              );
            } else {
              Navigator.pop(context);
              AppFlash.warning(
                context,
                _localizeCategoryErrorMessage(
                  context,
                  categoryProvider.errorMessage,
                  context.l10n.categoryUpdateFailed,
                ),
              );
              // Tránh để error message tồn tại và kích hoạt UI lỗi toàn màn hình.
              categoryProvider.clearError();
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
                _localizeCategoryErrorMessage(
                  context,
                  categoryProvider.errorMessage,
                  context.l10n.categoryAddFailed,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
