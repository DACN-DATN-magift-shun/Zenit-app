import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';
import 'package:zenit/features/setting_childs/money_source_manage/providers/money_source_provider.dart';

class MoneySourceSelectorDrawer extends StatefulWidget {
  final MoneySourceModel? selectedWallet;
  final Function(MoneySourceModel) onWalletSelected;

  const MoneySourceSelectorDrawer({
    super.key,
    this.selectedWallet,
    required this.onWalletSelected,
  });

  @override
  State<MoneySourceSelectorDrawer> createState() =>
      _MoneySourceSelectorDrawerState();
}

class _MoneySourceSelectorDrawerState extends State<MoneySourceSelectorDrawer> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final moneySourceProvider = context.read<MoneySourceProvider>();
      if (!moneySourceProvider.hasData) {
        moneySourceProvider.loadAllMoneySources();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MoneySourceModel> _filterWallets(List<MoneySourceModel> wallets) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return wallets;
    }

    return wallets.where((wallet) {
      return wallet.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return Consumer<MoneySourceProvider>(
      builder: (context, moneySourceProvider, child) {
        if (moneySourceProvider.isLoading &&
            moneySourceProvider.moneySources.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (moneySourceProvider.errorMessage != null) {
          return Center(
            child: Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.l),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Symbols.error_rounded,
                      size: 28,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.errorOccurred,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (moneySourceProvider.moneySources.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.l),
              child: Text(
                l10n.noData,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.neutralTextSecondary),
              ),
            ),
          );
        }

        final filteredWallets = _filterWallets(
          moneySourceProvider.moneySources,
        );

        return Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.all(AppSizes.l),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: l10n.searchForTag,
                  prefixIcon: const Icon(Symbols.search_rounded),
                  suffixIcon: _searchQuery.trim().isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(Symbols.close_rounded),
                        ),
                  filled: true,
                  fillColor: const Color(0xFFEBE4F0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.l,
                    vertical: AppSizes.m,
                  ),
                ),
              ),
            ),

            // Wallets list
            Expanded(
              child: filteredWallets.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noData,
                        style: TextStyle(color: colors.neutralTextSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSizes.l),
                      itemCount: filteredWallets.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSizes.s),
                      itemBuilder: (context, index) {
                        final wallet = filteredWallets[index];
                        final isSelected =
                            widget.selectedWallet?.id == wallet.id;
                        return _buildWalletOptionTile(
                          context,
                          wallet: wallet,
                          isSelected: isSelected,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWalletOptionTile(
    BuildContext context, {
    required MoneySourceModel wallet,
    required bool isSelected,
  }) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onWalletSelected(wallet);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.m,
          vertical: AppSizes.m,
        ),
        decoration: BoxDecoration(
          color: colors.neutralBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
          border: Border.all(
            color: isSelected
                ? colors.primaryMain
                : colors.neutralBorder.withValues(alpha: 0.6),
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Material(
              color: wallet.backgroundColor,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.s),
                child: Icon(
                  wallet.iconData,
                  color: wallet.iconColor,
                  size: AppSizes.textXXL,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.neutralTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    wallet.note.isEmpty ? _emptyNoteText(context) : wallet.note,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatWalletCurrency(wallet.amount),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.neutralTextPrimary,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Symbols.check_circle_rounded,
                    color: colors.primaryMain,
                    size: 18,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _emptyNoteText(BuildContext context) {
    return _isVietnamese(context) ? 'Không có ghi chú' : 'No note';
  }

  String _formatWalletCurrency(int amount) {
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

  bool _isVietnamese(BuildContext context) {
    return Localizations.localeOf(context).languageCode.toLowerCase() == 'vi';
  }
}
