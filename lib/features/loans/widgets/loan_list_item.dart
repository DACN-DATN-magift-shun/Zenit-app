import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/loans/models/loan_model.dart';

class LoanListItem extends StatelessWidget {
  static const double _itemRadius = 24;

  const LoanListItem({
    super.key,
    required this.loan,
    required this.onTap,
    required this.onDelete,
  });

  final LoanModel loan;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';
    final isLoan = loan.type == 0;

    final typeText = isLoan
        ? (isVietnamese ? 'Cho vay' : 'Loan')
        : (isVietnamese ? 'Đi vay' : 'Debt');

    final amountFormatter = NumberFormat.currency(
      locale: isVietnamese ? 'vi_VN' : 'en_US',
      symbol: isVietnamese ? 'đ' : 'VND ',
      decimalDigits: 0,
    );

    final amountText = amountFormatter.format(loan.amount);
    final dueDateText = DateFormat('dd/MM/yyyy').format(loan.dueDate);
    final dateText = DateFormat('dd/MM/yyyy').format(loan.date);

    final typeColor = isLoan ? colors.successText : colors.errorText;
    final typeBgColor = isLoan
        ? colors.successBackground
        : colors.errorBackground;

    final statusText = () {
      switch (loan.status) {
        case 1:
          return isVietnamese ? 'Hoàn thành' : 'Completed';
        case 2:
          return isVietnamese ? 'Đã huỷ' : 'Canceled';
        default:
          return isVietnamese ? 'Đang nợ' : 'Ongoing';
      }
    }();

    final statusColor = () {
      switch (loan.status) {
        case 1:
          return colors.successText;
        case 2:
          return colors.errorText;
        default:
          return colors.neutralTextSecondary;
      }
    }();

    final statusBgColor = () {
      switch (loan.status) {
        case 1:
          return colors.successBackground;
        case 2:
          return colors.errorBackground;
        default:
          return colors.neutralSurface;
      }
    }();

    return Slidable(
      key: ValueKey(loan.id.isEmpty ? '${loan.name}-${loan.amount}' : loan.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.5,
        children: [
          CustomSlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: colors.neutralBackground,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.xs,
              vertical: AppSizes.s,
            ),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.errorBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
              ),
              child: Text(
                isVietnamese ? 'Xoá' : 'Delete',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.errorIcon,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          CustomSlidableAction(
            onPressed: (ctx) => Slidable.of(ctx)?.close(),
            backgroundColor: colors.neutralBackground,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.xs,
              vertical: AppSizes.s,
            ),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.neutralSurface,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
              ),
              child: Text(
                isVietnamese ? 'Huỷ' : 'Cancel',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.neutralTextSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_itemRadius),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.m),
          padding: const EdgeInsets.all(AppSizes.l),
          decoration: BoxDecoration(
            color: colors.neutralBackground,
            borderRadius: BorderRadius.circular(_itemRadius),
            border: Border.all(
              color: colors.neutralBorder.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      loan.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.neutralTextPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.l,
                      vertical: AppSizes.m,
                    ),
                    decoration: BoxDecoration(
                      color: typeBgColor,
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadiusLarge,
                      ),
                    ),
                    child: Text(
                      typeText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.m),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.l,
                      vertical: AppSizes.m,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadiusLarge,
                      ),
                    ),
                    child: Text(
                      statusText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.m),
              Text(
                amountText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.neutralTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.s),
              Text(
                '${isVietnamese ? 'Ngày tạo' : 'Date'}: $dateText',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.neutralTextSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.s),
              Text(
                '${isVietnamese ? 'Đến hạn' : 'Due date'}: $dueDateText',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.neutralTextSecondary,
                ),
              ),
              if (loan.note.trim().isNotEmpty) ...[
                const SizedBox(height: AppSizes.s),
                Text(
                  loan.note,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.neutralTextPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
