import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/forms/form_fields/custom_text_form_field.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_flash.dart';

import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/utils/category_color_palette.dart';

/// Data class để trả về khi submit form
class AddCategoryData {
  final String name;
  final double? expenseLimit;
  final String icon;
  final String? color;
  final String? backgroundColor;
  final int groupType;

  AddCategoryData({
    required this.name,
    this.expenseLimit,
    required this.icon,
    this.color,
    this.backgroundColor,
    required this.groupType,
  });
}

class AddCategoryFormController {
  _AddCategoryFormState? _state;

  void submit() {
    _state?._handleSubmit();
  }

  void _attach(_AddCategoryFormState state) {
    _state = state;
  }

  void _detach(_AddCategoryFormState state) {
    if (_state == state) {
      _state = null;
    }
  }
}

class AddCategoryForm extends StatefulWidget {
  const AddCategoryForm({
    super.key,
    required this.groupType,
    required this.groupName,
    this.onSubmit,
    this.initialName,
    this.initialExpenseLimit,
    this.initialIcon,
    this.isEditMode = false,
    this.controller,
  });

  /// Loại group (0-5)
  final int groupType;

  /// Tên group để hiển thị
  final String groupName;

  /// Callback khi submit form thành công
  final void Function(AddCategoryData data)? onSubmit;

  // Initial values for editing
  final String? initialName;
  final double? initialExpenseLimit;
  final String? initialIcon;
  
  /// Có phải đang ở chế độ edit không (true = edit, false = add new)
  final bool isEditMode;
  final AddCategoryFormController? controller;

  @override
  State<AddCategoryForm> createState() => _AddCategoryFormState();
}

class _AddCategoryFormState extends State<AddCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _expenseLimitController = TextEditingController();

  String? _selectedIcon;
  int? _selectedGroupType;
  
  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _selectedGroupType = widget.groupType;
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
    if (widget.initialExpenseLimit != null) {
      _expenseLimitController.text = widget.initialExpenseLimit.toString();
    }
    if (widget.initialIcon != null) {
      _selectedIcon = widget.initialIcon;
    }
  }

  static const List<IconItem> _availableIcons = [
    // Neccessary
    IconItem(icon: Symbols.shopping_cart_rounded, name: 'shopping_cart_rounded'),
    IconItem(icon: Symbols.restaurant_rounded, name: 'restaurant_rounded'),

    // Savings
    IconItem(icon: Symbols.account_balance_rounded, name: 'account_balance_rounded'),
    IconItem(icon: Symbols.trending_up_rounded, name: 'trending_up_rounded'),

    // SelfDevelopment
    IconItem(icon: Symbols.school_rounded, name: 'school_rounded'),
    IconItem(icon: Symbols.menu_book_rounded, name: 'menu_book_rounded'),

    // Entertainment
    IconItem(icon: Symbols.movie_rounded, name: 'movie_rounded'),
    IconItem(icon: Symbols.fitness_center_rounded, name: 'fitness_center_rounded'),
  ];

  // Available colors for picker (8 colors - 2 rows x 4 columns)
  // REMOVED - Không còn cho phép người dùng chọn màu

  @override
  void didUpdateWidget(covariant AddCategoryForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _nameController.dispose();
    _expenseLimitController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // Đóng keyboard trước khi submit để tránh conflict với navigation
    FocusScope.of(context).unfocus();
    
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedIcon == null) {
        AppFlash.warning(context, context.l10n.pleaseSelectIcon);
        return;
      }

      // Nếu là mode thêm mới, random một cặp màu
      String? colorHex;
      String? bgColorHex;
      
      if (!widget.isEditMode) {
        final randomColorPair = CategoryColorPalette.getRandomColorPair();
        colorHex = randomColorPair.iconColorHex;
        bgColorHex = randomColorPair.backgroundColorHex;
        
        print('=== Random Color Pair Selected ===');
        print('Icon Color: $colorHex');
        print('Background Color: $bgColorHex');
      } else {
        // Chế độ edit - không gửi màu (API edit không trả về màu)
        print('=== Edit Mode - No Color Data Sent ===');
      }

      final data = AddCategoryData(
        name: _nameController.text.trim(),
        expenseLimit: double.tryParse(_expenseLimitController.text.trim()),
        icon: _selectedIcon!,
        color: colorHex,
        backgroundColor: bgColorHex,
        groupType: _selectedGroupType ?? widget.groupType,
      );

      widget.onSubmit?.call(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category name
            CustomTextFormField(
              label: l10n.categoryName,
              hintText: l10n.enterCategoryName,
              controller: _nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterCategoryName;
                }
                return null;
              },
            ),

            const SizedBox(height: AppSizes.l),

            // Belong to group (selectable)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.belongToGroup,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.neutralTextSecondary,
                      ),
                ),
                const SizedBox(height: AppSizes.s),
                Container(
                  decoration: BoxDecoration(
                    color: colors.neutralSurface,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
                    border: Border.all(color: colors.neutralBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedGroupType ?? widget.groupType,
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.m),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
                      dropdownColor: colors.neutralSurface,
                      items: GroupType.values.map((type) {
                        return DropdownMenuItem<int>(
                          value: type.value,
                          child: Text(
                            _groupDisplayName(context, type.value),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedGroupType = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.l),

            // Expense limit
            CustomTextFormField(
              label: l10n.expenseLimit,
              hintText: l10n.enterExpenseLimitOptional,
              controller: _expenseLimitController,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: AppSizes.l),

            // Select icon
            Text(l10n.selectIcon, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSizes.m),
            _buildIconGrid(colors),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  String _groupDisplayName(BuildContext context, int groupType) {
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
        return l10n.groupNecessary;
    }
  }



  Widget _buildIconGrid(AppColorExtension colors) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.l),
      decoration: BoxDecoration(
        color: colors.neutralBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall),
      ),
      child: Wrap(
        spacing: AppSizes.l,
        runSpacing: AppSizes.l,
        children: _availableIcons.map((iconItem) {
          final isSelected = _selectedIcon == iconItem.name;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIcon = iconItem.name;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(AppSizes.m),
              decoration: BoxDecoration(
                color: isSelected ? colors.primaryMain : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  AppSizes.borderRadiusXSmall,
                ),
                border: Border.all(
                  color: isSelected ? colors.primaryMain : colors.neutralBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Icon(
                iconItem.icon,
                size: AppSizes.iconL,
                color: isSelected
                    ? colors.primaryText
                    : colors.neutralTextPrimary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Helper class cho icon item
class IconItem {
  final IconData icon;
  final String name;

  const IconItem({required this.icon, required this.name});
}
