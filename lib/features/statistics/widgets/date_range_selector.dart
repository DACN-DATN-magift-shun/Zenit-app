import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/theme/app_colors.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';


/// Widget để chọn khoảng thời gian cho thống kê
class DateRangeSelector extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;

  const DateRangeSelector({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateTap,
    required this.onEndDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(AppSizes.m),
      decoration: BoxDecoration(
        color: AppColors.light.secondaryMain,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDateButton(
              context,
              label: l10n.fromLabel,
              date: startDate,
              onTap: onStartDateTap,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.light.primaryMain,
              size: AppSizes.iconS,
            ),
          ),
          Expanded(
            child: _buildDateButton(
              context,
              label: l10n.toLabel,
              date: endDate,
              onTap: onEndDateTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(
    BuildContext context, {
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.l,
          vertical: AppSizes.s,
        ),
        decoration: BoxDecoration(
          color: AppColors.light.neutralBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall),
          border: Border.all(
            color: AppColors.light.neutralBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.light.neutralTextSecondary,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.light.neutralTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Icon(
                  Symbols.calendar_month_rounded,
                  size: AppSizes.iconS,
                  color: AppColors.light.primaryMain,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
