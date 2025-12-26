import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/layout/base_layout.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_drawer.dart';
// Đừng quên import cái widget mới tạo nhé
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
                final groupType = categoryProvider.categoryGroups.keys.elementAt(index);
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
                    onAdd: () => _showAddCategoryDrawer(context, groupType, group.name),
                    items: group.categories.map((category) {
                      
 
                      return CustomLongPressMenu<String>(
                        items: [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Symbols.edit,
                                  color: Theme.of(context).extension<AppColorExtension>()!.neutralTextPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Chỉnh sửa',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).extension<AppColorExtension>()!.neutralTextPrimary,
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
                                  color: Theme.of(context).extension<AppColorExtension>()!.errorIcon,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Xóa',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).extension<AppColorExtension>()!.errorText,
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
                            _showEditCategoryDrawer(context, groupType, group.name, category);
                          }
                        },
                        child: SingleCategory(
                          icon: _parseIcon(category.icon),
                          name: category.name,
                          iconColor: _parseColor(category.color),
                          backgroundColor: _parseColor(category.backgroundColor),
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
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa category này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      final categoryProvider = context.read<CategoryProvider>();
      
      final success = await categoryProvider.deleteCategory(category.id, groupType);
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa category')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(categoryProvider.errorMessage ?? 'Xóa thất bại'),
          ),
        );
      }
    }
  }

  // --- CÁC HÀM HELPER KHÁC ---

  Color _getGroupChipColor(int groupType) {
    switch (groupType) {
      case 0: return Theme.of(context).extension<AppColorExtension>()!.successIcon; 
      case 1: return Theme.of(context).extension<AppColorExtension>()!.primarySubtext; 
      case 2: return Theme.of(context).extension<AppColorExtension>()!.infoIcon; 
      case 3: return Theme.of(context).extension<AppColorExtension>()!.infoIcon; 
      case 4: return Theme.of(context).extension<AppColorExtension>()!.secondaryHover; 
      case 5: return Theme.of(context).extension<AppColorExtension>()!.primarySubtext; 
      default: return Theme.of(context).extension<AppColorExtension>()!.primarySubtext;
    }
  }

  IconData _getGroupChipIcon(int groupType) {
    switch (groupType) {
      case 0: return Symbols.home_filled;
      case 1: return Symbols.shopping_bag_rounded;
      case 2: return Symbols.attach_money_rounded;
      case 3: return Symbols.savings;
      case 4: return Symbols.trending_up;
      case 5: return Symbols.category;
      default: return Symbols.category;
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

  void _showEditCategoryDrawer(BuildContext context, int groupType, String groupName, CategoryModel category) {
    AppDrawer.showAsBottomSheet(
      context: context,
      title: 'Edit category',
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã cập nhật category: ${data.name}')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(categoryProvider.errorMessage ?? 'Cập nhật category thất bại'),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showAddCategoryDrawer(BuildContext context, int groupType, String groupName) {
    AppDrawer.showAsBottomSheet(
      context: context,
      title: 'Add a category', 
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