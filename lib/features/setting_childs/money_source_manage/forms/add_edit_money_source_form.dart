import 'package:flutter/material.dart';
import 'package:zenit/core/forms/form_fields/custom_text_form_field.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/utils/validators/money_source_manage_form_validator.dart';
import 'package:zenit/core/widgets/app_flash.dart';
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

class AddEditMoneySourceFormController {
  _AddEditMoneySourceFormState? _state;

  void submit() {
    _state?._handleSubmit();
  }

  void _attach(_AddEditMoneySourceFormState state) {
    _state = state;
  }

  void _detach(_AddEditMoneySourceFormState state) {
    if (_state == state) {
      _state = null;
    }
  }
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
    this.controller,
  });

  final String? initialName;
  final String? initialIconName;
  final int? initialAmount;
  final String? initialNote;
  final bool initialIsIncludeInTotalBalance;
  final bool isEditMode;
  final void Function(AddEditMoneySourceData data)? onSubmit;
  final AddEditMoneySourceFormController? controller;

  @override
  State<AddEditMoneySourceForm> createState() => _AddEditMoneySourceFormState();
}

class _AddEditMoneySourceFormState extends State<AddEditMoneySourceForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isSubmitting = false;

  String? _selectedIconName;
  bool _isIncludedInTotalBalance = true;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _nameController.text = widget.initialName ?? '';
    _amountController.text = widget.initialAmount?.toString() ?? '';
    _noteController.text = widget.initialNote ?? '';
    _selectedIconName = widget.initialIconName;
    _isIncludedInTotalBalance = widget.initialIsIncludeInTotalBalance;
  }

  @override
  void didUpdateWidget(covariant AddEditMoneySourceForm oldWidget) {
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
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() {
      _isSubmitting = true;
    });
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    if (_selectedIconName == null) {
      AppFlash.warning(context, context.l10n.pleaseSelectIcon);
      return;
    }

    final amountText = _amountController.text.trim();
    final parsedAmount = amountText.isEmpty ? 0 : int.tryParse(amountText);
    if (parsedAmount == null) {
      setState(() {
        _isSubmitting = false;
      });
      AppFlash.warning(context, context.l10n.enterValidAmount);
      return;
    }

    try {
      widget.onSubmit?.call(
        AddEditMoneySourceData(
          name: _nameController.text.trim(),
          iconName: _selectedIconName!,
          amount: parsedAmount,
          note: _noteController.text.trim(),
          isIncludeInTotalBalance: _isIncludedInTotalBalance,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
              validator: (value) =>
                  MoneySourceManageFormValidator.moneySourceName(
                    value,
                    isVietnamese: isVietnamese,
                  ),
            ),
            const SizedBox(height: AppSizes.l),
            CustomTextFormField(
              label: l10n.amount,
              hintText: l10n.enterAmount,
              controller: _amountController,
              keyboardType: TextInputType.number,
              validator: (value) => MoneySourceManageFormValidator.amount(
                value,
                invalidAmountMessage: l10n.enterValidAmount,
              ),
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
            const SizedBox(height: AppSizes.l),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text(widget.isEditMode ? l10n.saveChanges : l10n.chatSave),
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
