import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';

class MoneySourceListItem extends StatelessWidget {
  const MoneySourceListItem({
    super.key,
    required this.moneySource,
    this.onTap,
    this.onDelete,
  });

  final MoneySourceModel moneySource;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return Slidable(
      key: ValueKey('wallet-${moneySource.id}-${moneySource.name}'),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.5,
        children: [
          CustomSlidableAction(
            onPressed: (actionContext) {
              Slidable.of(actionContext)?.close();
              onDelete?.call();
            },
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
                context.l10n.delete,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.errorIcon,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          CustomSlidableAction(
            onPressed: (actionContext) => Slidable.of(actionContext)?.close(),
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
                context.l10n.cancel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.neutralTextSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.m),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.m,
            vertical: AppSizes.l,
          ),
          constraints: const BoxConstraints(minHeight: 72),
          decoration: BoxDecoration(
            color: colors.neutralBackground,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            border: Border.all(
              color: colors.neutralBorder.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              Material(
                color: moneySource.backgroundColor,
                borderRadius: BorderRadius.circular(
                  AppSizes.borderRadiusXSmall,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.m),
                  child: Icon(
                    moneySource.iconData,
                    color: moneySource.iconColor,
                    size: AppSizes.iconL,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      moneySource.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.neutralTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      moneySource.note.isEmpty
                          ? _emptyNoteText(context)
                          : moneySource.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.neutralTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.s),
              Text(
                _formatCurrency(moneySource.amount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.neutralTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _emptyNoteText(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'vi'
        ? 'Không có ghi chú'
        : 'No note';
  }

  String _formatCurrency(int amount) {
    final amountStr = amount.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = amountStr.length - 1; i >= 0; i--) {
      buffer.write(amountStr[i]);
      count++;
      if (count % 3 == 0 && i > 0 && amountStr[i - 1] != '-') {
        buffer.write('.');
      }
    }

    return '${buffer.toString().split('').reversed.join()}đ';
  }
}
