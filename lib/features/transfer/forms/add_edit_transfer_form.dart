import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:zenit/core/forms/form_fields/custom_text_form_field.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/button.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';
import 'package:zenit/features/setting_childs/money_source_manage/services/money_source_service.dart';
import 'package:zenit/features/transfer/models/money_transfer_model.dart';

class TransferFormData {
  const TransferFormData({
    required this.fromWalletId,
    required this.toWalletId,
    required this.amount,
    required this.transferDate,
    required this.note,
  });

  final String fromWalletId;
  final String toWalletId;
  final int amount;
  final DateTime transferDate;
  final String note;
}

class AddEditTransferForm extends StatefulWidget {
  const AddEditTransferForm({
    super.key,
    required this.onSubmit,
    this.initialTransfer,
  });

  final MoneyTransferModel? initialTransfer;
  final Future<void> Function(TransferFormData data) onSubmit;

  @override
  State<AddEditTransferForm> createState() => _AddEditTransferFormState();
}

class _AddEditTransferFormState extends State<AddEditTransferForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _moneySourceService = MoneySourceService();

  List<MoneySourceModel> _wallets = [];
  String? _selectedFromWalletId;
  String? _selectedToWalletId;
  DateTime _transferDate = DateTime.now();
  bool _isSubmitting = false;
  bool _isLoadingWallets = true;
  String? _walletError;

  @override
  void initState() {
    super.initState();

    final initial = widget.initialTransfer;
    _amountController.text = initial?.amount.toString() ?? '';
    _noteController.text = initial?.note ?? '';
    _selectedFromWalletId = initial?.fromWalletId;
    _selectedToWalletId = initial?.toWalletId;
    _transferDate = initial?.transferDate ?? DateTime.now();

    _loadWallets();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadWallets() async {
    setState(() {
      _isLoadingWallets = true;
      _walletError = null;
    });

    try {
      final wallets = await _moneySourceService.getAllMoneySources();

      if (!mounted) {
        return;
      }

      setState(() {
        _wallets = wallets;
        if (_selectedFromWalletId != null &&
            !_wallets.any((item) => item.id == _selectedFromWalletId)) {
          _selectedFromWalletId = null;
        }
        if (_selectedToWalletId != null &&
            !_wallets.any((item) => item.id == _selectedToWalletId)) {
          _selectedToWalletId = null;
        }
        _isLoadingWallets = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _walletError = e.toString();
        _isLoadingWallets = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    if (_isLoadingWallets) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_walletError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isVietnamese ? 'Không thể tải danh sách ví' : 'Cannot load wallets',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSizes.s),
          Text(_walletError!, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSizes.l),
          FilledButton.tonal(
            onPressed: _loadWallets,
            child: Text(isVietnamese ? 'Thử lại' : 'Retry'),
          ),
        ],
      );
    }

    if (_wallets.length < 2) {
      return Text(
        isVietnamese
            ? 'Cần ít nhất 2 ví để tạo giao dịch chuyển tiền.'
            : 'At least 2 wallets are required to create a transfer.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWalletDropdown(
              context,
              label: isVietnamese ? 'Ví nguồn' : 'From wallet',
              value: _selectedFromWalletId,
              onChanged: (value) {
                setState(() {
                  _selectedFromWalletId = value;
                });
              },
            ),
            const SizedBox(height: AppSizes.l),
            _buildWalletDropdown(
              context,
              label: isVietnamese ? 'Ví đích' : 'To wallet',
              value: _selectedToWalletId,
              onChanged: (value) {
                setState(() {
                  _selectedToWalletId = value;
                });
              },
            ),
            if (_selectedFromWalletId != null &&
                _selectedFromWalletId == _selectedToWalletId) ...[
              const SizedBox(height: AppSizes.s),
              Text(
                isVietnamese
                    ? 'Ví nguồn và ví đích phải khác nhau'
                    : 'From wallet and to wallet must be different',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: AppSizes.textS,
                ),
              ),
            ],
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.l,
                  vertical: 18,
                ),
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
            _buildDatePicker(context),
            const SizedBox(height: AppSizes.l),
            CustomTextFormField(
              label: isVietnamese ? 'Ghi chú' : 'Note',
              hintText: isVietnamese
                  ? 'Nhập ghi chú (tuỳ chọn)'
                  : 'Enter note (optional)',
              controller: _noteController,
              maxLines: 3,
            ),
            const SizedBox(height: AppSizes.xl),
            Center(
              child: AppButton(
                text: isVietnamese ? 'Lưu' : 'Save',
                icon: Icons.check_circle_rounded,
                onPressed: _isSubmitting ? null : _submit,
                isEnabled: !_isSubmitting,
                width: 160,
                backgroundColor: colors.primaryMain,
                foregroundColor: colors.primaryText,
              ),
            ),
            const SizedBox(height: AppSizes.l),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletDropdown(
    BuildContext context, {
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSizes.s),
        DropdownButtonFormField<String>(
          value: value,
          items: _wallets
              .where((wallet) => wallet.id.isNotEmpty)
              .map(
                (wallet) => DropdownMenuItem<String>(
                  value: wallet.id,
                  child: Text(wallet.name),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: isVietnamese ? 'Chọn ví' : 'Select wallet',
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
          ),
          validator: (selected) {
            if (selected == null || selected.isEmpty) {
              return isVietnamese ? 'Vui lòng chọn ví' : 'Please select wallet';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';
    final dateText = DateFormat('dd/MM/yyyy').format(_transferDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isVietnamese ? 'Ngày chuyển' : 'Transfer date',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.m),
        FilledButton.tonal(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _transferDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null && mounted) {
              setState(() {
                _transferDate = picked;
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
          child: Text(dateText),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fromWalletId = _selectedFromWalletId;
    final toWalletId = _selectedToWalletId;

    if (fromWalletId == null || toWalletId == null) {
      return;
    }

    if (fromWalletId == toWalletId) {
      setState(() {});
      return;
    }

    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(
        TransferFormData(
          fromWalletId: fromWalletId,
          toWalletId: toWalletId,
          amount: amount,
          transferDate: _transferDate,
          note: _noteController.text.trim(),
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
}
