import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';
import 'package:zenit/features/transfer/models/money_transfer_model.dart';

class TransferListItem extends StatelessWidget {
  const TransferListItem({
    super.key,
    required this.transfer,
    this.onTap,
    this.onDelete,
  });

  final MoneyTransferModel transfer;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';

    final fromWalletName = transfer.fromWallet?.name.trim().isNotEmpty == true
        ? transfer.fromWallet!.name
        : (isVietnamese ? 'Ví nguồn' : 'From wallet');

    final toWalletName = transfer.toWallet?.name.trim().isNotEmpty == true
        ? transfer.toWallet!.name
        : (isVietnamese ? 'Ví đích' : 'To wallet');

    final formattedAmount = _formatCurrency(transfer.amount);
    final formattedDate = _formatDate(transfer.transferDate);

    return Slidable(
      key: ValueKey(
        transfer.id.isEmpty
            ? '${transfer.fromWalletId}-${transfer.toWalletId}-${transfer.transferDate.millisecondsSinceEpoch}'
            : transfer.id,
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
                isVietnamese ? 'Xoá' : 'Delete',
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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.m,
            vertical: AppSizes.l,
          ),
          constraints: const BoxConstraints(minHeight: 72),
          decoration: BoxDecoration(
            color: colors.neutralBackground,
            border: Border(
              bottom: BorderSide(color: colors.neutralBorder, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              _buildLeadingMedia(
                fromWallet: transfer.fromWallet,
                toWallet: transfer.toWallet,
              ),
              const SizedBox(width: AppSizes.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$fromWalletName → $toWalletName',
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
                        Expanded(
                          child: Text(
                            transfer.note.trim().isEmpty
                                ? (isVietnamese
                                      ? 'Chuyển giữa 2 ví'
                                      : 'Wallet to wallet transfer')
                                : transfer.note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.neutralTextSecondary),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '•',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.neutralTextSecondary),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.neutralTextSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                formattedAmount,
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

  Widget _buildLeadingMedia({
    required TransferWalletModel? fromWallet,
    required TransferWalletModel? toWallet,
  }) {
    final fromBg =
        _parseColor(fromWallet?.backgroundColor) ?? const Color(0xFFE8EEF9);
    final toBg =
        _parseColor(toWallet?.backgroundColor) ?? const Color(0xFFDDF3EA);

    final fromIcon = MoneySourceIconMapper.fromName(
      fromWallet?.icon ?? 'account_balance_wallet_rounded',
    );
    final toIcon = MoneySourceIconMapper.fromName(
      toWallet?.icon ?? 'account_balance_wallet_rounded',
    );

    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 12,
            child: _buildWalletBubble(fromBg, fromIcon),
          ),
          Positioned(right: 0, top: 0, child: _buildWalletBubble(toBg, toIcon)),
          Positioned(
            left: 18,
            top: 20,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Symbols.arrow_forward_rounded,
                size: 13,
                color: Color(0xFF465260),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletBubble(Color bgColor, IconData icon) {
    final iconColor = bgColor.computeLuminance() > 0.55
        ? const Color(0xFF111111)
        : Colors.white;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }

  Color? _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return null;
    try {
      String hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
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
