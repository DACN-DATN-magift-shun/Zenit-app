import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/goals/models/goal_model.dart';

class GoalListItem extends StatelessWidget {
  static const double _itemRadius = 24;

  const GoalListItem({
    super.key,
    required this.goal,
    required this.onTap,
    required this.onDelete,
  });

  final GoalModel goal;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';

    final amountFormatter = NumberFormat.currency(
      locale: isVietnamese ? 'vi_VN' : 'en_US',
      symbol: isVietnamese ? 'đ' : 'VND ',
      decimalDigits: 0,
    );

    final dueDateText = DateFormat('dd/MM/yyyy').format(goal.dueDate);
    final statusText = switch (goal.status) {
      GoalStatus.ongoing => isVietnamese ? 'Đang thực hiện' : 'Ongoing',
      GoalStatus.completed => isVietnamese ? 'Hoàn thành' : 'Completed',
      GoalStatus.paused => isVietnamese ? 'Tạm dừng' : 'Paused',
    };

    final statusColor = switch (goal.status) {
      GoalStatus.ongoing => const Color(0xFF1F4E8C),
      GoalStatus.completed => const Color(0xFF166534),
      GoalStatus.paused => const Color(0xFF92400E),
    };

    final statusBackground = switch (goal.status) {
      GoalStatus.ongoing => const Color(0xFFDCEAFF),
      GoalStatus.completed => const Color(0xFFDDF5E7),
      GoalStatus.paused => const Color(0xFFFFE7C2),
    };

    final goalColor = _parseHexColor(goal.backgroundColor, fallback: const Color(0xFF8CCAF7));

    return Slidable(
      key: ValueKey(goal.id.isEmpty ? '${goal.name}-${goal.targetAmount}' : goal.id),
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colors.neutralTextPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.s),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.m,
                            vertical: AppSizes.s,
                          ),
                          decoration: BoxDecoration(
                            color: statusBackground,
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadiusLarge,
                            ),
                          ),
                          child: Text(
                            statusText,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.m),
                    Text(
                      '${isVietnamese ? 'Hiện có' : 'Current'}: ${amountFormatter.format(goal.currentAmount)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.neutralTextPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSizes.s),
                    Text(
                      '${isVietnamese ? 'Mục tiêu' : 'Target'}: ${amountFormatter.format(goal.targetAmount)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.neutralTextSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.s),
                    Text(
                      '${isVietnamese ? 'Hạn chót' : 'Due date'}: $dueDateText',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.neutralTextSecondary,
                      ),
                    ),
                    if (goal.note.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSizes.s),
                      Text(
                        goal.note,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.neutralTextPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.m),
              SizedBox(
                width: 78,
                height: 78,
                child: LiquidCircularProgressIndicator(
                  value: goal.progress,
                  valueColor: AlwaysStoppedAnimation(goalColor),
                  backgroundColor: goalColor.withValues(alpha: 0.18),
                  borderColor: goalColor.withValues(alpha: 0.7),
                  borderWidth: 1.3,
                  direction: Axis.vertical,
                  center: Text(
                    '${(goal.progress * 100).round()}%',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.neutralTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
}
