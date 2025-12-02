import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/layout/base_layout.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_drawer.dart';
import 'package:zenit/features/setting_childs/category_manage/forms/add_category_form.dart';
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
      context.read<CategoryProvider>().loadAllCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      appBar: CommonAppBar(
        title: 'Category Manage',
        showReturnIcon: true,
        onBack: () {
          Navigator.pop(context);
        },
      ),
      child: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (categoryProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đã xảy ra lỗi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categoryProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => categoryProvider.loadAllCategories(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (!categoryProvider.hasData) {
            return Center(
              child: Text(
                'Chưa có dữ liệu',
                style: Theme.of(context).textTheme.titleMedium,
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

                if (group.categories.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GroupCategory(
                    title: group.name,
                    titleChipColor: _getGroupChipColor(groupType),
                    chipIcon: _getGroupChipIcon(groupType),
                    onAdd: () =>
                        _showAddCategoryDrawer(context, groupType, group.name),
                    items: group.categories.map((category) {
                      // capture position của long press
                      Offset tapPosition = Offset.zero;

                      return GestureDetector(
                        onLongPressStart: (details) {
                          tapPosition = details.globalPosition;
                        },
                        onLongPress: () async {
                          final overlay =
                              Overlay.of(context).context.findRenderObject()
                                  as RenderBox;
                          final selected = await showMenu<String>(
                            context: context,
                            position: RelativeRect.fromRect(
                              Rect.fromCenter(
                                center: tapPosition,
                                width: 1,
                                height: 1,
                              ),
                              Offset.zero & overlay.size,
                            ),
                            items: [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Xóa'),
                              ),
                            ],
                          );

                          if (selected == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Xác nhận'),
                                content: const Text(
                                  'Bạn có chắc muốn xóa category này?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Xóa'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              // gọi provider để xóa (groupType hiện tại)
                              final success = await categoryProvider
                                  .deleteCategory(category.id, groupType);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã xóa category'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      categoryProvider.errorMessage ??
                                          'Xóa thất bại',
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: SingleCategory(
                          icon: _parseIcon(category.icon),
                          name: category.name,
                        ),
                      );
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

  Color _getGroupChipColor(int groupType) {
    switch (groupType) {
      case 0:
        return Theme.of(
          context,
        ).extension<AppColorExtension>()!.successIcon; // Chi tiêu thiết yếu
      case 1:
        return Theme.of(
          context,
        ).extension<AppColorExtension>()!.primarySubtext; // Chi tiêu cá nhân
      case 2:
        return Theme.of(
          context,
        ).extension<AppColorExtension>()!.infoIcon; // Thu nhập
      case 3:
        return Theme.of(
          context,
        ).extension<AppColorExtension>()!.infoIcon; // Tiết kiệm
      case 4:
        return Theme.of(
          context,
        ).extension<AppColorExtension>()!.secondaryHover; // Đầu tư
      case 5:
        return Theme.of(
          context,
        ).extension<AppColorExtension>()!.primarySubtext; // Khác
      default:
        return Theme.of(context).extension<AppColorExtension>()!.primarySubtext;
    }
  }

  IconData _getGroupChipIcon(int groupType) {
    switch (groupType) {
      case 0:
        return Symbols.home_filled; // Chi tiêu thiết yếu
      case 1:
        return Symbols.shopping_bag_rounded; // Chi tiêu cá nhân
      case 2:
        return Symbols.attach_money_rounded; // Thu nhập
      case 3:
        return Symbols.savings; // Tiết kiệm
      case 4:
        return Symbols.trending_up; // Đầu tư
      case 5:
        return Symbols.category; // Khác
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
    };

    return iconMap[iconName] ?? Symbols.category;
  }

  void _showAddCategoryDrawer(
    BuildContext context,
    int groupType,
    String groupName,
  ) {
    AppDrawer.showAsBottomSheet(
      context: context,
      title: 'Add a category',
      showDragHandle: true,
      body: AddCategoryForm(
        groupType: groupType,
        groupName: groupName,
        onSubmit: (data) async {
          final categoryProvider = context.read<CategoryProvider>();
          
          final success = await categoryProvider.addCategory(
            name: data.name,
            icon: data.icon,
            groupType: data.groupType,
            expenseLimit: data.expenseLimit ?? 0,
            expenseAlertThreshold: 0,
          );

          if (context.mounted) {
            Navigator.pop(context);
            
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã thêm category: ${data.name}')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(categoryProvider.errorMessage ?? 'Thêm category thất bại'),
                ),
              );
            }
          }
        },
      ),
    );
  }
}


