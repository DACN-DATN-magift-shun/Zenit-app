import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:zenit/core/forms/form_fields/custom_text_form_field.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/loans/models/loan_model.dart';

class LoanFormData {
  const LoanFormData({
    required this.name,
    required this.type,
    required this.amount,
    required this.date,
    required this.dueDate,
    required this.note,
    required this.status,
  });

  final String name;
  final int type;
  final int amount;
  final DateTime date;
  final DateTime dueDate;
  final String note;
  final int status;
}

class AddEditLoanFormController {
  _AddEditLoanFormState? _state;

  Future<void> submit() async {
    await _state?._submit();
  }

  void _attach(_AddEditLoanFormState state) {
    _state = state;
  }

  void _detach(_AddEditLoanFormState state) {
    if (_state == state) {
      _state = null;
    }
  }
}

class AddEditLoanForm extends StatefulWidget {
  const AddEditLoanForm({
    super.key,
    required this.onSubmit,
    this.initialLoan,
    this.controller,
  });

  final LoanModel? initialLoan;
  final Future<void> Function(LoanFormData data) onSubmit;
  final AddEditLoanFormController? controller;

  @override
  State<AddEditLoanForm> createState() => _AddEditLoanFormState();
}

class _AddEditLoanFormState extends State<AddEditLoanForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late int _selectedType;
  late int _selectedStatus;
  late DateTime _date;
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    final initial = widget.initialLoan;
    _selectedType = initial?.type ?? 0;
    _selectedStatus = initial?.status ?? 0;
    _date = initial?.date ?? DateTime.now();
    _dueDate = initial?.dueDate ?? DateTime.now();

    _nameController.text = initial?.name ?? '';
    _amountController.text = initial?.amount.toString() ?? '';
    _noteController.text = initial?.note ?? '';
  }

  @override
  void didUpdateWidget(covariant AddEditLoanForm oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextFormField(
              label: isVietnamese ? 'Tên khoản vay / nợ' : 'Loan / debt name',
              hintText: isVietnamese
                  ? 'Nhập tên khoản vay hoặc nợ'
                  : 'Enter loan or debt name',
              controller: _nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return isVietnamese
                      ? 'Tên không được để trống'
                      : 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.l),
            Text(
              isVietnamese ? 'Trạng thái' : 'Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.m),
            SegmentedButton<int>(
              segments: [
                ButtonSegment<int>(value: 0, label: Text(isVietnamese ? 'Đang nợ' : 'Ongoing')),
                ButtonSegment<int>(value: 1, label: Text(isVietnamese ? 'Hoàn thành' : 'Completed')),
                ButtonSegment<int>(value: 2, label: Text(isVietnamese ? 'Đã huỷ' : 'Canceled')),
              ],
              selected: {_selectedStatus},
              style: ButtonStyle(
                side: const MaterialStatePropertyAll(BorderSide.none),
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  final isSelected = states.contains(MaterialState.selected);
                  return isSelected
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Theme.of(context).colorScheme.surfaceVariant;
                }),
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  final isSelected = states.contains(MaterialState.selected);
                  return isSelected
                      ? Theme.of(context).colorScheme.onSecondaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant;
                }),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedStatus = selection.first;
                });
              },
            ),
            const SizedBox(height: AppSizes.l),
            Text(
              isVietnamese ? 'Loại' : 'Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.m),
            SegmentedButton<int>(
              segments: [
                ButtonSegment<int>(
                  value: 0,
                  label: Text(isVietnamese ? 'Cho vay' : 'Loan'),
                ),
                ButtonSegment<int>(
                  value: 1,
                  label: Text(isVietnamese ? 'Đi vay' : 'Debt'),
                ),
              ],
              selected: {_selectedType},
              style: ButtonStyle(
                side: const MaterialStatePropertyAll(BorderSide.none),
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  final isSelected = states.contains(MaterialState.selected);
                  return isSelected
                      ? const Color(0xFFD2E4FF)
                      : Theme.of(context).colorScheme.surfaceContainerHigh;
                }),
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  return Theme.of(context).colorScheme.onSurface;
                }),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedType = selection.first;
                });
              },
            ),
            const SizedBox(height: AppSizes.l),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: isVietnamese ? 'Số tiền' : 'Amount',
                hintText: isVietnamese ? 'Nhập số tiền' : 'Enter amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).extension<AppColorExtension>()!.neutralBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).extension<AppColorExtension>()!.neutralBorder,
                  ),
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
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
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
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return isVietnamese
                      ? 'Số tiền không được để trống'
                      : 'Amount is required';
                }

                final amount = int.tryParse(value);
                if (amount == null || amount <= 0) {
                  return isVietnamese
                      ? 'Số tiền phải lớn hơn 0'
                      : 'Amount must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.l),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    context,
                    label: isVietnamese ? 'Ngày tạo' : 'Date',
                    value: _date,
                    onPick: (picked) {
                      setState(() {
                        _date = picked;
                        if (_dueDate.isBefore(_date)) {
                          _dueDate = _date;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.m),
                Expanded(
                  child: _buildDatePicker(
                    context,
                    label: isVietnamese ? 'Ngày đến hạn' : 'Due date',
                    value: _dueDate,
                    onPick: (picked) {
                      setState(() {
                        _dueDate = picked;
                      });
                    },
                  ),
                ),
              ],
            ),
            if (_dueDate.isBefore(_date)) ...[
              const SizedBox(height: AppSizes.s),
              Text(
                isVietnamese
                    ? 'Ngày đến hạn phải lớn hơn hoặc bằng ngày tạo'
                    : 'Due date must be greater than or equal to date',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: AppSizes.textS,
                ),
              ),
            ],
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dueDate.isBefore(_date)) {
      setState(() {});
      return;
    }

    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      return;
    }

    await widget.onSubmit(
      LoanFormData(
        name: _nameController.text.trim(),
        type: _selectedType,
        amount: amount,
        date: _date,
        dueDate: _dueDate,
        note: _noteController.text.trim(),
        status: _selectedStatus,
      ),
    );
  }
}
