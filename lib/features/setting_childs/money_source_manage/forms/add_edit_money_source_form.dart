import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/forms/form_fields/custom_text_form_field.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_flash.dart';
import 'package:zenit/core/widgets/button.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';

class AddEditMoneySourceData {
  final String name;
  final String iconName;
  final int amount;
  final String note;
  final bool isIncludeInTotalBalance;

  const AddEditMoneySourceData({
    required this.name,
    required this.iconName,
    required this.amount,
    required this.note,
    required this.isIncludeInTotalBalance,
  });
}

class AddEditMoneySourceForm extends StatefulWidget {
  const AddEditMoneySourceForm({
    super.key,
    this.initialName,
    this.initialIconName,
    this.initialAmount,
    this.initialNote,
    this.initialIsIncludeInTotalBalance = true,
    this.isEditMode = false,
    this.onSubmit,
  });

  final String? initialName;
  final String? initialIconName;
  final int? initialAmount;
  final String? initialNote;
  final bool initialIsIncludeInTotalBalance;
  final bool isEditMode;
  final void Function(AddEditMoneySourceData data)? onSubmit;

  @override
  State<AddEditMoneySourceForm> createState() => _AddEditMoneySourceFormState();
}

class _AddEditMoneySourceFormState extends State<AddEditMoneySourceForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedIconName;
  bool _isIncludedInTotalBalance = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _amountController.text = widget.initialAmount?.toString() ?? '';
    _noteController.text = widget.initialNote ?? '';
    _selectedIconName = widget.initialIconName;
    _isIncludedInTotalBalance = widget.initialIsIncludeInTotalBalance;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedIconName == null) {
      AppFlash.warning(context, context.l10n.pleaseSelectIcon);
      return;
    }

    final amountText = _amountController.text.trim();
    final parsedAmount = amountText.isEmpty ? 0 : int.tryParse(amountText);
    if (parsedAmount == null || parsedAmount < 0) {
      AppFlash.warning(context, context.l10n.enterValidAmount);
      return;
    }

    widget.onSubmit?.call(
      AddEditMoneySourceData(
        name: _nameController.text.trim(),
        iconName: _selectedIconName!,
        amount: parsedAmount,
        note: _noteController.text.trim(),
        isIncludeInTotalBalance: _isIncludedInTotalBalance,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextFormField(
              label: isVietnamese ? 'Tên nguồn tiền' : 'Money source name',
              hintText: isVietnamese
                  ? 'Nhập tên nguồn tiền'
                  : 'Enter money source name',
              controller: _nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return isVietnamese
                      ? 'Vui lòng nhập tên nguồn tiền'
                      : 'Please enter money source name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.l),
            CustomTextFormField(
              label: l10n.amount,
              hintText: l10n.enterAmount,
              controller: _amountController,
              keyboardType: TextInputType.number,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) {
                  return null;
                }
                final amount = int.tryParse(text);
                if (amount == null || amount < 0) {
                  return l10n.enterValidAmount;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.l),
            CustomTextFormField(
              label: l10n.note,
              hintText: isVietnamese ? 'Nhập ghi chú' : 'Enter note',
              controller: _noteController,
              maxLines: 3,
            ),
            const SizedBox(height: AppSizes.l),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _isIncludedInTotalBalance,
              onChanged: (value) {
                setState(() {
                  _isIncludedInTotalBalance = value;
                });
              },
              title: Text(
                isVietnamese
                    ? 'Tính vào tổng số dư'
                    : 'Include in total balance',
              ),
              subtitle: Text(
                isVietnamese
                    ? 'Bật nếu số dư của wallet này được tính vào tổng tài sản'
                    : 'Turn on if this wallet balance should count toward total assets',
              ),
            ),
            const SizedBox(height: AppSizes.l),
            Text(
              l10n.selectIcon,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.m),
            _buildIconGrid(colors),
            const SizedBox(height: AppSizes.xl),
            Center(
              child: AppButton(
                text: l10n.done,
                icon: Symbols.check_circle_rounded,
                onPressed: _handleSubmit,
                width: 160,
              ),
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
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
        children: MoneySourceIconMapper.availableOptions.map((iconOption) {
          final isSelected = _selectedIconName == iconOption.name;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIconName = iconOption.name;
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
                iconOption.icon,
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
