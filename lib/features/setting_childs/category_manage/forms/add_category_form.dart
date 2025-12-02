import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/forms/form_fields/custom_text_form_field.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/button.dart';

/// Data class để trả về khi submit form
class AddCategoryData {
  final String name;
  final double? expenseLimit;
  final String icon;
  final int groupType;

  AddCategoryData({
    required this.name,
    this.expenseLimit,
    required this.icon,
    required this.groupType,
  });
}

class AddCategoryForm extends StatefulWidget {
  const AddCategoryForm({
    super.key,
    required this.groupType,
    required this.groupName,
    this.onSubmit,
  });

  /// Loại group (0-5)
  final int groupType;

  /// Tên group để hiển thị
  final String groupName;

  /// Callback khi submit form thành công
  final void Function(AddCategoryData data)? onSubmit;

  @override
  State<AddCategoryForm> createState() => _AddCategoryFormState();
}

class _AddCategoryFormState extends State<AddCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _expenseLimitController = TextEditingController();

  String? _selectedIcon;
  static const List<IconItem> _availableIcons = [
    // Neccessary
    IconItem(
      icon: Symbols.shopping_cart_rounded,
      name: 'shopping_cart_rounded',
    ),
    IconItem(icon: Symbols.restaurant_rounded, name: 'restaurant_rounded'),

    // Savings
    IconItem(
      icon: Symbols.account_balance_rounded,
      name: 'account_balance_rounded',
    ),
    IconItem(icon: Symbols.trending_up_rounded, name: 'trending_up_rounded'),

    // SelfDevelopment
    IconItem(icon: Symbols.school_rounded, name: 'school_rounded'),
    IconItem(icon: Symbols.menu_book_rounded, name: 'menu_book_rounded'),

    // Entertainment
    IconItem(icon: Symbols.movie_rounded, name: 'movie_rounded'),
    IconItem(
      icon: Symbols.fitness_center_rounded,
      name: 'fitness_center_rounded',
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _expenseLimitController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedIcon == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn icon')));
        return;
      }

      final data = AddCategoryData(
        name: _nameController.text.trim(),
        expenseLimit: double.tryParse(_expenseLimitController.text.trim()),
        icon: _selectedIcon!,
        groupType: widget.groupType,
      );

      widget.onSubmit?.call(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category name
            CustomTextFormField(
              label: 'Category name',
              hintText: 'Enter category name',
              controller: _nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter category name';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSizes.l),

            // Belong to group (read-only)
            _buildReadOnlyField(
              context: context,
              label: 'Belong to group',
              value: '${widget.groupType} - ${widget.groupName}',
              colors: colors,
            ),

            const SizedBox(height: AppSizes.l),

            // Expense limit
            CustomTextFormField(
              label: 'Expense limit',
              hintText: 'Enter expense limit (optional)',
              controller: _expenseLimitController,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: AppSizes.l),

            // Select icon
            Text('Select icon', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSizes.m),
            _buildIconGrid(colors),

            const SizedBox(height: AppSizes.xl),

            // Done button
            Center(
              child: AppButton(
                text: 'Done',
                icon: Symbols.check_circle_rounded,
                onPressed: _handleSubmit,
                width: 140,
              ),
            ),

            const SizedBox(height: AppSizes.l),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required BuildContext context,
    required String label,
    required String value,
    required AppColorExtension colors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: colors.primaryMain,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: AppSizes.textM,
            ),
          ),
        ),
      ],
    );
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
