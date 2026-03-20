import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/transaction/models/transaction_model.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final category = transaction.category;

    // Parse colors from category
    final iconColor = _parseColor(category?.color) ?? colors.primaryMain;
    final bgColor = _parseColor(category?.backgroundColor) ?? colors.neutralSurface;

    // Format amount
    final formattedAmount = _formatCurrency(transaction.amount);

    // Format date
    final formattedDate = _formatDate(transaction.transactionDate);

    // Determine if expense or income based on groupType
    // final isExpense = category?.groupType != 2; // groupType 2 is income
    // final amountColor = isExpense ? colors.errorText : colors.successText;
    // final amountPrefix = isExpense ? '-' : '+';

    return Slidable(
      key: ValueKey(
        transaction.id ??
            '${transaction.title}-${transaction.transactionDate.millisecondsSinceEpoch}',
      ),
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
                l10n.delete,
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
                l10n.cancel,
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.m,
            vertical: AppSizes.m,
          ),
          decoration: BoxDecoration(
            color: colors.neutralBackground,
            border: Border(
              bottom: BorderSide(
                color: colors.neutralBorder,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Category icon
              Material(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.s),
                  child: Icon(
                    _parseIcon(category?.icon ?? ''),
                    fill: 1.0,
                    weight: 400,
                    grade: 0.25,
                    color: iconColor,
                    size: AppSizes.textXXL,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.m),

              // Transaction info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.neutralTextPrimary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          category?.name ?? l10n.unknown,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colors.neutralTextSecondary,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '•',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colors.neutralTextSecondary,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colors.neutralTextSecondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              Text(
                // '$amountPrefix$formattedAmount',
                formattedAmount,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      // color: amountColor,
                      color: colors.neutralTextPrimary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _parseIcon(String iconName) {
    final iconMap = <String, IconData>{
      'home': Symbols.home,
      'shopping_cart': Symbols.shopping_cart,
      'restaurant': Symbols.restaurant,
      'directions_car': Symbols.directions_car,
      'directions_bus': Symbols.directions_bus,
      'local_hospital': Symbols.local_hospital,
      'school': Symbols.school,
      'work': Symbols.work,
      'attach_money': Symbols.attach_money,
      'savings': Symbols.savings,
      'trending_up': Symbols.trending_up,
      'spa': Symbols.spa,
      'sports_esports': Symbols.sports_esports,
      'flight': Symbols.flight,
      'pets': Symbols.pets,
      'child_care': Symbols.child_care,
      'shopping_cart_rounded': Symbols.shopping_cart_rounded,
      'restaurant_rounded': Symbols.restaurant_rounded,
      'account_balance_rounded': Symbols.account_balance_rounded,
      'trending_up_rounded': Symbols.trending_up_rounded,
      'school_rounded': Symbols.school_rounded,
      'menu_book_rounded': Symbols.menu_book_rounded,
      'movie_rounded': Symbols.movie_rounded,
      'fitness_center_rounded': Symbols.fitness_center_rounded,
    };

    return iconMap[iconName] ?? Symbols.category;
  }

  Color? _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return null;
    try {
      String hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return null;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  String _formatCurrency(int amount) {
    // Simple Vietnamese currency format
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
