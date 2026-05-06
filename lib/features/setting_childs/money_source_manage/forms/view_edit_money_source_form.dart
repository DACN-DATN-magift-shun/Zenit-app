import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_flash.dart';
import 'package:zenit/features/setting_childs/money_source_manage/forms/add_edit_money_source_form.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';
import 'package:zenit/features/setting_childs/money_source_manage/providers/money_source_provider.dart';
import 'package:zenit/features/setting_childs/money_source_manage/services/money_source_service.dart';

class ViewEditMoneySourceForm extends StatefulWidget {
  const ViewEditMoneySourceForm({
    super.key,
    required this.moneySourceId,
    required this.isEditing,
    this.onUpdated,
    this.controller,
  });

  final String moneySourceId;
  final ValueNotifier<bool> isEditing;
  final Future<void> Function()? onUpdated;
  final AddEditMoneySourceFormController? controller;

  @override
  State<ViewEditMoneySourceForm> createState() =>
      _ViewEditMoneySourceFormState();
}

class _ViewEditMoneySourceFormState extends State<ViewEditMoneySourceForm> {
  final MoneySourceService _moneySourceService = MoneySourceService();

  bool _isLoading = true;
  String? _errorMessage;
  MoneySourceModel? _moneySource;

  @override
  void initState() {
    super.initState();
    _loadMoneySourceDetail();
  }

  Future<void> _loadMoneySourceDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _moneySourceService.getMoneySourceById(
        widget.moneySourceId,
      );
      if (!mounted) return;
      setState(() {
        _moneySource = detail;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleUpdate(AddEditMoneySourceData data) async {
    final provider = context.read<MoneySourceProvider>();

    final success = await provider.updateMoneySource(
      id: widget.moneySourceId,
      name: data.name,
      icon: data.iconName,
      amount: data.amount,
      note: data.note,
      isIncludeInTotalBalance: data.isIncludeInTotalBalance,
    );

    if (!mounted) return;

    if (success) {
      AppFlash.success(
        context,
        Localizations.localeOf(context).languageCode == 'vi'
            ? 'Đã cập nhật nguồn tiền'
            : 'Money source updated',
      );
      widget.isEditing.value = false;
      await _loadMoneySourceDetail();
      await widget.onUpdated?.call();
    } else {
      AppFlash.error(
        context,
        provider.errorMessage ?? context.l10n.deleteFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.errorOccurred,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.s),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.l),
            ElevatedButton(
              onPressed: _loadMoneySourceDetail,
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_moneySource == null) {
      return Center(
        child: Text(
          Localizations.localeOf(context).languageCode == 'vi'
              ? 'Không tìm thấy ví'
              : 'Wallet not found',
        ),
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: widget.isEditing,
      builder: (context, isEditing, child) {
        if (isEditing) {
          return AddEditMoneySourceForm(
            controller: widget.controller,
            initialName: _moneySource!.name,
            initialIconName: _moneySource!.iconName,
            initialAmount: _moneySource!.amount,
            initialNote: _moneySource!.note,
            initialIsIncludeInTotalBalance:
                _moneySource!.isIncludeInTotalBalance,
            isEditMode: true,
            onSubmit: _handleUpdate,
          );
        }

        return _buildReadOnlyContent(context, _moneySource!);
      },
    );
  }

  Widget _buildReadOnlyContent(
    BuildContext context,
    MoneySourceModel moneySource,
  ) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';

    Widget row({required String label, required String value}) {
      return Container(
        margin: const EdgeInsets.only(bottom: AppSizes.m),
        padding: const EdgeInsets.all(AppSizes.m),
        decoration: BoxDecoration(
          color: colors.neutralBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.neutralTextSecondary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.neutralTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: moneySource.backgroundColor,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
              ),
              child: Icon(
                moneySource.iconData,
                color: moneySource.iconColor,
                size: AppSizes.iconL,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.l),
          row(
            label: isVietnamese ? 'Tên ví' : 'Wallet name',
            value: moneySource.name,
          ),
          row(
            label: isVietnamese ? 'Số dư' : 'Balance',
            value: _formatCurrency(moneySource.amount),
          ),
          row(
            label: isVietnamese ? 'Ghi chú' : 'Note',
            value: moneySource.note.isEmpty
                ? (isVietnamese ? 'Không có ghi chú' : 'No note')
                : moneySource.note,
          ),
          row(
            label: isVietnamese
                ? 'Tính vào tổng số dư'
                : 'Include in total balance',
            value: moneySource.isIncludeInTotalBalance
                ? (isVietnamese ? 'Có' : 'Yes')
                : (isVietnamese ? 'Không' : 'No'),
          ),
          const SizedBox(height: AppSizes.l),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    final amountStr = amount.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = amountStr.length - 1; i >= 0; i--) {
      buffer.write(amountStr[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }

    return '${buffer.toString().split('').reversed.join()}đ';
  }
}
