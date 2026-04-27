import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:zenit/core/forms/form_fields/custom_text_form_field.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/goals/forms/add_edit_goal_form.dart';
import 'package:zenit/features/goals/models/goal_model.dart';

class ViewEditGoalFormController {
  _ViewEditGoalFormState? _state;
  final ValueNotifier<bool> isEditing = ValueNotifier(false);
  final ValueNotifier<bool> isSaving = ValueNotifier(false);

  Future<void> startEditing() async {
    await _state?._startEditing();
  }

  Future<void> saveChanges() async {
    await _state?._saveChanges();
  }

  void cancelEditing() {
    _state?._cancelEditing();
  }

  void _attach(_ViewEditGoalFormState state) {
    _state = state;
  }

  void _detach(_ViewEditGoalFormState state) {
    if (_state == state) {
      _state = null;
    }
  }

  void dispose() {
    isEditing.dispose();
    isSaving.dispose();
  }
}

class ViewEditGoalForm extends StatefulWidget {
  const ViewEditGoalForm({
    super.key,
    required this.initialGoal,
    required this.onSubmit,
    this.controller,
  });

  final GoalModel initialGoal;
  final Future<bool> Function(GoalFormData data) onSubmit;
  final ViewEditGoalFormController? controller;

  @override
  State<ViewEditGoalForm> createState() => _ViewEditGoalFormState();
}

class _ViewEditGoalFormState extends State<ViewEditGoalForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();
  final _noteController = TextEditingController();

  late GoalModel _goal;
  late DateTime _dueDate;
  late GoalStatus _status;
  late GoalIconOption _selectedIcon;

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _hydrateFromGoal(widget.initialGoal);
    widget.controller?.isEditing.value = _isEditing;
    widget.controller?.isSaving.value = _isSaving;
  }

  @override
  void didUpdateWidget(covariant ViewEditGoalForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
      widget.controller?.isEditing.value = _isEditing;
      widget.controller?.isSaving.value = _isSaving;
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

  void _hydrateFromGoal(GoalModel goal) {
    _goal = goal;
    _dueDate = goal.dueDate;
    _status = goal.status;
    _selectedIcon = goalIconOptionByName(goal.icon);

    _nameController.text = goal.name;
    _targetAmountController.text = goal.targetAmount.toString();
    _currentAmountController.text = goal.currentAmount.toString();
    _noteController.text = goal.note;
  }

  void _setEditing(bool value) {
    if (!mounted) {
      widget.controller?.isEditing.value = value;
      return;
    }

    setState(() {
      _isEditing = value;
    });
    widget.controller?.isEditing.value = value;
  }

  void _setSaving(bool value) {
    if (mounted) {
      setState(() {
        _isSaving = value;
      });
    }
    widget.controller?.isSaving.value = value;
  }

  Future<void> _startEditing() async {
    if (_isSaving) {
      return;
    }
    FocusScope.of(context).unfocus();
    _setEditing(true);
  }

  Future<void> _saveChanges() async {
    if (_isSaving || !_isEditing) {
      return;
    }

    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final targetAmount = int.tryParse(_targetAmountController.text.trim());
    final currentAmount = int.tryParse(_currentAmountController.text.trim());
    if (targetAmount == null || currentAmount == null || targetAmount <= 0) {
      return;
    }

    _setSaving(true);
    final success = await widget.onSubmit(
      GoalFormData(
        name: _nameController.text.trim(),
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        backgroundColor: _selectedIcon.backgroundColorHex,
        icon: _selectedIcon.name,
        dueDate: _dueDate,
        note: _noteController.text.trim(),
        status: _status,
      ),
    );

    if (success) {
      final updatedGoal = _goal.copyWith(
        name: _nameController.text.trim(),
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        backgroundColor: _selectedIcon.backgroundColorHex,
        icon: _selectedIcon.name,
        dueDate: _dueDate,
        note: _noteController.text.trim(),
        status: _status,
      );

      if (mounted) {
        setState(() {
          _goal = updatedGoal;
        });
      }
      _setEditing(false);
    }

    _setSaving(false);
  }

  void _cancelEditing() {
    if (_isSaving || !_isEditing) {
      return;
    }

    FocusScope.of(context).unfocus();
    _hydrateFromGoal(_goal);
    _formKey.currentState?.reset();
    _setEditing(false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AbsorbPointer(
        absorbing: _isSaving,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressHeader(context),
              const SizedBox(height: AppSizes.l),
              _isEditing ? _buildEditBody(context) : _buildViewBody(context),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final progressColor = _parseHexColor(
      _goal.backgroundColor,
      fallback: const Color(0xFF8CCAF7),
    );

    return Center(
      child: SizedBox(
        width: 152,
        height: 152,
        child: LiquidCircularProgressIndicator(
          value: _goal.progress,
          valueColor: AlwaysStoppedAnimation(progressColor),
          backgroundColor: progressColor.withValues(alpha: 0.18),
          borderColor: progressColor.withValues(alpha: 0.72),
          borderWidth: 1.8,
          direction: Axis.vertical,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                goalIconDataByName(_goal.icon),
                color: colors.neutralTextPrimary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                '${(_goal.progress * 100).round()}%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colors.neutralTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewBody(BuildContext context) {
    final isVietnamese = _isVietnamese(context);
    final formatter = NumberFormat.currency(
      locale: isVietnamese ? 'vi_VN' : 'en_US',
      symbol: isVietnamese ? 'đ' : 'VND ',
      decimalDigits: 0,
    );
    final currentAmountText = formatter.format(_goal.currentAmount);
    final targetAmountText = formatter.format(_goal.targetAmount);
    final remainingDays = _remainingDays(_goal.dueDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            _goal.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.l),
        _buildFieldRow(
          context,
          label: isVietnamese ? 'Hiện có' : 'Current',
          value: currentAmountText,
        ),
        _buildFieldRow(
          context,
          label: isVietnamese ? 'Mục tiêu' : 'Target',
          value: targetAmountText,
        ),
        const SizedBox(height: AppSizes.s),
        _buildAmountProgressBar(
          context,
          label: isVietnamese ? 'Tiến độ' : 'Saving progress',
          value: _goal.progress,
          subtext: '$currentAmountText / $targetAmountText',
        ),
        const SizedBox(height: AppSizes.s),
        _buildFieldRow(
          context,
          label: isVietnamese ? 'Hạn chót' : 'Due date',
          value: DateFormat('dd/MM/yyyy').format(_goal.dueDate),
        ),
        const SizedBox(height: AppSizes.s),
        _buildRemainingDaysText(
          context,
          remainingDays: remainingDays,
        ),
        _buildFieldRow(
          context,
          label: isVietnamese ? 'Trạng thái' : 'Status',
          valueWidget: _buildStatusChip(context, _goal.status),
        ),
        const SizedBox(height: AppSizes.m),
        Text(
          isVietnamese ? 'Ghi chú' : 'Note',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSizes.s),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.m),
          decoration: BoxDecoration(
            color: Theme.of(context).extension<AppColorExtension>()!.neutralBackground,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          ),
          child: Text(
            _goal.note.trim().isEmpty
                ? (isVietnamese ? 'Không có ghi chú' : 'No note')
                : _goal.note,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildEditBody(BuildContext context) {
    final isVietnamese = _isVietnamese(context);

    return Column(
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
        _buildAmountInput(
          context,
          controller: _targetAmountController,
          label: isVietnamese ? 'Số tiền mục tiêu' : 'Target amount',
          hint: isVietnamese ? 'Nhập số tiền mục tiêu' : 'Enter target amount',
        ),
        const SizedBox(height: AppSizes.l),
        _buildAmountInput(
          context,
          controller: _currentAmountController,
          label: isVietnamese ? 'Số tiền hiện có' : 'Current amount',
          hint: isVietnamese ? 'Nhập số tiền hiện có' : 'Enter current amount',
        ),
        const SizedBox(height: AppSizes.l),
        _buildDateInput(context),
        const SizedBox(height: AppSizes.l),
        Text(
          isVietnamese ? 'Biểu tượng' : 'Icon',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.m),
        _buildIconGrid(context),
        const SizedBox(height: AppSizes.l),
        Text(
          isVietnamese ? 'Trạng thái' : 'Status',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.m),
        Center(child: _buildStatusSegment(context)),
        const SizedBox(height: AppSizes.l),
        CustomTextFormField(
          label: isVietnamese ? 'Ghi chú' : 'Note',
          hintText: isVietnamese
              ? 'Nhập ghi chú (tuỳ chọn)'
              : 'Enter note (optional)',
          controller: _noteController,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildAmountInput(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    final isVietnamese = _isVietnamese(context);

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: _outlinedDecoration(context).copyWith(
        labelText: label,
        hintText: hint,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return isVietnamese ? '$label không được để trống' : '$label is required';
        }

        final amount = int.tryParse(value.trim());
        if (amount == null || amount < 0) {
          return isVietnamese ? '$label không hợp lệ' : '$label is invalid';
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

  Widget _buildDateInput(BuildContext context) {
    final isVietnamese = _isVietnamese(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isVietnamese ? 'Hạn chót' : 'Due date',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.m),
        FilledButton.tonal(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _dueDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() {
                _dueDate = picked;
              });
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
          child: Text(DateFormat('dd/MM/yyyy').format(_dueDate)),
        ),
      ],
    );
  }

  Widget _buildIconGrid(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;

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
          final isSelected = _selectedIcon.name == iconOption.name;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIcon = iconOption;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(AppSizes.m),
              decoration: BoxDecoration(
                color: isSelected ? colors.primaryMain : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall),
                border: Border.all(
                  color: isSelected ? colors.primaryMain : colors.neutralBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Icon(
                iconOption.icon,
                size: AppSizes.iconL,
                color: isSelected ? colors.primaryText : colors.neutralTextPrimary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusSegment(BuildContext context) {
    final isVietnamese = _isVietnamese(context);

    return SegmentedButton<GoalStatus>(
      segments: [
        ButtonSegment<GoalStatus>(
          value: GoalStatus.ongoing,
          label: Text(isVietnamese ? 'Đang thực hiện' : 'Ongoing'),
        ),
        ButtonSegment<GoalStatus>(
          value: GoalStatus.completed,
          label: Text(isVietnamese ? 'Hoàn thành' : 'Completed'),
        ),
        ButtonSegment<GoalStatus>(
          value: GoalStatus.paused,
          label: Text(isVietnamese ? 'Tạm dừng' : 'Paused'),
        ),
      ],
      selected: {_status},
      style: ButtonStyle(
        side: const WidgetStatePropertyAll(BorderSide.none),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return isSelected
              ? const Color(0xFFD2E4FF)
              : Theme.of(context).colorScheme.surfaceContainerHigh;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return Theme.of(context).colorScheme.onSurface;
        }),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
      onSelectionChanged: (selection) {
        setState(() {
          _status = selection.first;
        });
      },
    );
  }

  Widget _buildStatusChip(BuildContext context, GoalStatus status) {
    final isVietnamese = _isVietnamese(context);

    final text = switch (status) {
      GoalStatus.ongoing => isVietnamese ? 'Đang thực hiện' : 'Ongoing',
      GoalStatus.completed => isVietnamese ? 'Hoàn thành' : 'Completed',
      GoalStatus.paused => isVietnamese ? 'Tạm dừng' : 'Paused',
    };

    final textColor = switch (status) {
      GoalStatus.ongoing => const Color(0xFF1F4E8C),
      GoalStatus.completed => const Color(0xFF166534),
      GoalStatus.paused => const Color(0xFF92400E),
    };

    final backgroundColor = switch (status) {
      GoalStatus.ongoing => const Color(0xFFDCEAFF),
      GoalStatus.completed => const Color(0xFFDDF5E7),
      GoalStatus.paused => const Color(0xFFFFE7C2),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.s),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildFieldRow(
    BuildContext context, {
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.neutralTextPrimary,
            ),
          ),
          const SizedBox(width: AppSizes.l),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: valueWidget ??
                  Text(
                    value ?? '',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.neutralTextSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountProgressBar(
    BuildContext context, {
    required String label,
    required double value,
    required String subtext,
  }) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final clampedValue = value.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.neutralTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.s),
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: const Color(0xFFE7EEF8),
            border: Border.all(color: const Color(0xFFCAD8EA)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: clampedValue,
              backgroundColor: const Color(0xFFE7EEF8),
              valueColor: const AlwaysStoppedAnimation(
                Color(0xFF2F80ED),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtext,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colors.neutralTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRemainingDaysText(
    BuildContext context, {
    required int remainingDays,
  }) {
    final isVietnamese = _isVietnamese(context);
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    final text = remainingDays <= 0
        ? (isVietnamese ? 'Đã đến hạn' : 'Deadline reached')
        : (isVietnamese
              ? 'Bạn còn $remainingDays ngày nữa'
              : '$remainingDays days remaining');

    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: remainingDays <= 0
            ? Theme.of(context).colorScheme.error
            : colors.neutralTextSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  int _remainingDays(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadline = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return deadline.difference(today).inDays;
  }

  InputDecoration _outlinedDecoration(BuildContext context) {
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

  Color _parseHexColor(String rawColor, {required Color fallback}) {
    var hex = rawColor.trim();
    if (hex.isEmpty) {
      return fallback;
    }

    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    }

    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    if (hex.length != 8) {
      return fallback;
    }

    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) {
      return fallback;
    }

    return Color(parsed);
  }

  bool _isVietnamese(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'vi';
  }
}
