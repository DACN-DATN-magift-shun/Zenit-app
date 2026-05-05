import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:zenit/core/forms/form_fields/custom_text_form_field.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_flash.dart';
import 'package:zenit/features/goals/models/goal_model.dart';

class GoalFormData {
  const GoalFormData({
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.backgroundColor,
    required this.icon,
    required this.dueDate,
    required this.note,
    required this.status,
  });

  final String name;
  final int targetAmount;
  final int currentAmount;
  final String backgroundColor;
  final String icon;
  final DateTime dueDate;
  final String note;
  final GoalStatus status;
}

class GoalIconOption {
  const GoalIconOption({
    required this.name,
    required this.icon,
    required this.backgroundColorHex,
  });

  final String name;
  final IconData icon;
  final String backgroundColorHex;
}

const List<GoalIconOption> goalIconOptions = [
  GoalIconOption(
    name: 'flag',
    icon: Icons.flag_rounded,
    backgroundColorHex: '#8CCAF7',
  ),
  GoalIconOption(
    name: 'savings',
    icon: Icons.savings_rounded,
    backgroundColorHex: '#7DD3A7',
  ),
  GoalIconOption(
    name: 'home',
    icon: Icons.home_rounded,
    backgroundColorHex: '#A7C7FF',
  ),
  GoalIconOption(
    name: 'directions_car',
    icon: Icons.directions_car_rounded,
    backgroundColorHex: '#B8B5FF',
  ),
  GoalIconOption(
    name: 'flight',
    icon: Icons.flight_takeoff_rounded,
    backgroundColorHex: '#F6C177',
  ),
  GoalIconOption(
    name: 'school',
    icon: Icons.school_rounded,
    backgroundColorHex: '#A5D8FF',
  ),
  GoalIconOption(
    name: 'celebration',
    icon: Icons.celebration_rounded,
    backgroundColorHex: '#F7A8B8',
  ),
  GoalIconOption(
    name: 'shopping_cart',
    icon: Icons.shopping_cart_rounded,
    backgroundColorHex: '#FFDCA8',
  ),
  GoalIconOption(
    name: 'medical_services',
    icon: Icons.medical_services_rounded,
    backgroundColorHex: '#FFB4A2',
  ),
  GoalIconOption(
    name: 'fitness_center',
    icon: Icons.fitness_center_rounded,
    backgroundColorHex: '#BDE0FE',
  ),
  GoalIconOption(
    name: 'favorite',
    icon: Icons.favorite_rounded,
    backgroundColorHex: '#FFC8DD',
  ),
  GoalIconOption(
    name: 'laptop_mac',
    icon: Icons.laptop_mac_rounded,
    backgroundColorHex: '#CDEAC0',
  ),
];

GoalIconOption goalIconOptionByName(String? iconName) {
  if (iconName == null || iconName.trim().isEmpty) {
    return goalIconOptions.first;
  }

  for (final option in goalIconOptions) {
    if (option.name == iconName) {
      return option;
    }
  }

  return goalIconOptions.first;
}

IconData goalIconDataByName(String? iconName) {
  return goalIconOptionByName(iconName).icon;
}

class AddEditGoalFormController {
  _AddEditGoalFormState? _state;

  Future<void> submit() async {
    await _state?._submit();
  }

  void _attach(_AddEditGoalFormState state) {
    _state = state;
  }

  void _detach(_AddEditGoalFormState state) {
    if (_state == state) {
      _state = null;
    }
  }
}

class AddEditGoalForm extends StatefulWidget {
  const AddEditGoalForm({
    super.key,
    required this.onSubmit,
    this.initialGoal,
    this.controller,
  });

  final GoalModel? initialGoal;
  final Future<void> Function(GoalFormData data) onSubmit;
  final AddEditGoalFormController? controller;

  @override
  State<AddEditGoalForm> createState() => _AddEditGoalFormState();
}

class _AddEditGoalFormState extends State<AddEditGoalForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();
  final _noteController = TextEditingController();

  late GoalIconOption _selectedIconOption;
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    final initial = widget.initialGoal;

    _selectedIconOption = goalIconOptionByName(initial?.icon);
    _dueDate = initial?.dueDate ?? DateTime.now();

    _nameController.text = initial?.name ?? '';
    _targetAmountController.text = initial?.targetAmount.toString() ?? '';
    _currentAmountController.text = initial?.currentAmount.toString() ?? '';
    _noteController.text = initial?.note ?? '';
  }

  @override
  void didUpdateWidget(covariant AddEditGoalForm oldWidget) {
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
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextFormField(
              label: isVietnamese ? 'Tên mục tiêu' : 'Goal name',
              hintText: isVietnamese
                  ? 'Nhập tên mục tiêu tài chính'
                  : 'Enter your financial goal name',
              controller: _nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return isVietnamese
                      ? 'Tên mục tiêu không được để trống'
                      : 'Goal name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.l),
            _buildNumberField(
              context,
              controller: _targetAmountController,
              label: isVietnamese ? 'Số tiền mục tiêu' : 'Target amount',
              hintText: isVietnamese
                  ? 'Nhập số tiền mục tiêu'
                  : 'Enter target amount',
            ),
            const SizedBox(height: AppSizes.l),
            _buildNumberField(
              context,
              controller: _currentAmountController,
              label: isVietnamese ? 'Số tiền hiện có' : 'Current amount',
              hintText: isVietnamese
                  ? 'Nhập số tiền hiện có'
                  : 'Enter current amount',
            ),
            const SizedBox(height: AppSizes.l),
            _buildDatePicker(
              context,
              label: isVietnamese ? 'Hạn chót' : 'Due date',
              value: _dueDate,
              onPick: (picked) {
                setState(() {
                  _dueDate = picked;
                });
              },
            ),
            const SizedBox(height: AppSizes.l),
            Text(
              isVietnamese ? 'Biểu tượng' : 'Icon',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.m),
            _buildIconGrid(colors),
            const SizedBox(height: AppSizes.l),
            CustomTextFormField(
              label: isVietnamese ? 'Ghi chú' : 'Note',
              hintText: isVietnamese
                  ? 'Nhập ghi chú (tuỳ chọn)'
                  : 'Enter note (optional)',
              controller: _noteController,
              maxLines: 3,
            ),
            const SizedBox(height: AppSizes.l),
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
        children: goalIconOptions.map((iconOption) {
          final isSelected = _selectedIconOption.name == iconOption.name;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIconOption = iconOption;
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

  Widget _buildNumberField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hintText,
  }) {
    final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: _inputDecoration(context).copyWith(
        labelText: label,
        hintText: hintText,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return isVietnamese
              ? '$label không được để trống'
              : '$label is required';
        }

        final amount = int.tryParse(value.trim());
        if (amount == null || amount < 0) {
          return isVietnamese
              ? '$label không hợp lệ'
              : '$label is invalid';
        }

        if (controller == _targetAmountController && amount <= 0) {
          return isVietnamese
              ? 'Số tiền mục tiêu phải lớn hơn 0'
              : 'Target amount must be greater than 0';
        }

        return null;
      },
    );
  }

  Widget _buildDatePicker(
    BuildContext context, {
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onPick,
  }) {
    final dateText = DateFormat('dd/MM/yyyy').format(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSizes.m),
        FilledButton.tonal(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              onPick(picked);
            }
          },
          style: FilledButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: const Size.fromHeight(56),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.m),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(dateText),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.neutralBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.neutralBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.l,
        vertical: 18,
      ),
      constraints: const BoxConstraints(minHeight: 56),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedIconOption.name.trim().isEmpty) {
      AppFlash.warning(
        context,
        Localizations.localeOf(context).languageCode == 'vi'
            ? 'Vui lòng chọn biểu tượng'
            : 'Please select an icon',
      );
      return;
    }

    final targetAmount = int.tryParse(_targetAmountController.text.trim());
    final currentAmount = int.tryParse(_currentAmountController.text.trim());

    if (targetAmount == null || currentAmount == null || targetAmount <= 0) {
      return;
    }

    await widget.onSubmit(
      GoalFormData(
        name: _nameController.text.trim(),
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        backgroundColor: _selectedIconOption.backgroundColorHex,
        icon: _selectedIconOption.name,
        dueDate: _dueDate,
        note: _noteController.text.trim(),
        status: GoalStatus.ongoing,
      ),
    );
  }
}
