import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/layout/base_layout.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_confirm_dialog.dart';
import 'package:zenit/core/widgets/app_drawer.dart';
import 'package:zenit/core/widgets/app_flash.dart';
import 'package:zenit/features/transfer/forms/add_edit_transfer_form.dart';
import 'package:zenit/features/transfer/models/money_transfer_model.dart';
import 'package:zenit/features/transfer/providers/money_transfer_provider.dart';
import 'package:zenit/features/transfer/widgets/transfer_list_item.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoneyTransferProvider>().loadTransfers();
    });
  }

  void _onSearchTextChanged() {
    if (mounted) {
      setState(() {});
    }

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) {
        return;
      }
      context.read<MoneyTransferProvider>().setSearchKeyword(
        _searchController.text,
      );
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BaseLayout(
      appBar: CommonAppBar(
        title: l10n.transferTitle,
        showReturnIcon: true,
        onBack: () => Navigator.pop(context),
      ),
      child: Consumer<MoneyTransferProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && !provider.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && !provider.hasData) {
            return _buildErrorState(context, provider);
          }

          return Stack(
            children: [
              Column(
                children: [
                  _buildSearchToolbar(context, provider),
                  const SizedBox(height: AppSizes.m),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: provider.refreshTransfers,
                      child: provider.transfers.isEmpty
                          ? _buildEmptyState(context)
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 96),
                              itemCount: provider.transfers.length,
                              itemBuilder: (context, index) {
                                final item = provider.transfers[index];
                                final animationDelayMs = index < 8
                                    ? index * 40
                                    : 320;

                                return Animate(
                                  delay: Duration(
                                    milliseconds: animationDelayMs,
                                  ),
                                  effects: [
                                    FadeEffect(
                                      duration: 280.ms,
                                      curve: Curves.easeOut,
                                    ),
                                    SlideEffect(
                                      begin: const Offset(0, 0.08),
                                      end: const Offset(0, 0),
                                      duration: 320.ms,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ],
                                  child: TransferListItem(
                                    transfer: item,
                                    onTap: () => _openEditTransferDrawer(item),
                                    onDelete: () => _handleDelete(item),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: AppSizes.l,
                bottom: AppSizes.l,
                child: FloatingActionButton(
                  onPressed: _showAddTransferDrawer,
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, size: 30, weight: 900, fill: 1),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchToolbar(
    BuildContext context,
    MoneyTransferProvider provider,
  ) {
    final isVietnamese = _isVietnamese(context);
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: isVietnamese
                  ? 'Tìm theo ví hoặc ghi chú'
                  : 'Search by wallet or note',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.trim().isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        provider.setSearchKeyword('');
                      },
                      icon: const Icon(Icons.close),
                    ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(
                  color: colors.neutralBorder.withValues(alpha: 0.8),
                  width: 1.3,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(
                  color: colors.neutralBorder.withValues(alpha: 0.8),
                  width: 1.3,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.6,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              prefixIconConstraints: const BoxConstraints(minWidth: 48),
              suffixIconConstraints: const BoxConstraints(minWidth: 48),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    MoneyTransferProvider provider,
  ) {
    final isVietnamese = _isVietnamese(context);

    return Center(
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.errorContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusXLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isVietnamese ? 'Đã xảy ra lỗi' : 'Something went wrong',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: AppSizes.s),
              Text(
                provider.errorMessage ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: AppSizes.l),
              FilledButton.tonal(
                onPressed: provider.loadTransfers,
                child: Text(isVietnamese ? 'Thử lại' : 'Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isVietnamese = _isVietnamese(context);
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSizes.xl * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.swap_horiz_rounded,
                size: 42,
                color: colors.neutralTextSecondary,
              ),
              const SizedBox(height: AppSizes.s),
              Text(
                isVietnamese
                    ? 'Chưa có giao dịch chuyển tiền nào'
                    : 'No transfer transactions yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.neutralTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddTransferDrawer() {
    final isVietnamese = _isVietnamese(context);
    final formController = AddEditTransferFormController();

    AppDrawer.showAsBottomSheet(
      context: context,
      title: isVietnamese ? 'Thêm chuyển tiền' : 'Add transfer',
      showDragHandle: true,
      headerActions: [
        GestureDetector(
          onTap: () async {
            await formController.submit();
          },
          child: Container(
            padding: const EdgeInsets.all(AppSizes.s),
            decoration: BoxDecoration(
              color: Theme.of(context).extension<AppColorExtension>()!.neutralBackground,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
            ),
            child: Icon(
              Symbols.check_rounded,
              size: AppSizes.iconL,
              color: Theme.of(context).extension<AppColorExtension>()!.primaryActive,
            ),
          ),
        ),
      ],
      body: AddEditTransferForm(
        controller: formController,
        onSubmit: (data) async {
          final provider = context.read<MoneyTransferProvider>();
          final success = await provider.addTransfer(
            fromWalletId: data.fromWalletId,
            toWalletId: data.toWalletId,
            amount: data.amount,
            transferDate: data.transferDate,
            note: data.note,
          );

          if (!mounted) return;

          if (success) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            AppFlash.success(
              context,
              isVietnamese ? 'Đã thêm giao dịch chuyển tiền' : 'Transfer added',
            );
          } else {
            AppFlash.error(
              context,
              provider.errorMessage ??
                  (isVietnamese
                      ? 'Không thể thêm giao dịch'
                      : 'Cannot add transfer'),
            );
          }
        },
      ),
    );
  }

  void _openEditTransferDrawer(MoneyTransferModel transfer) {
    final isVietnamese = _isVietnamese(context);
    final formController = AddEditTransferFormController();

    AppDrawer.showAsBottomSheet(
      context: context,
      title: isVietnamese ? 'Cập nhật chuyển tiền' : 'Update transfer',
      showDragHandle: true,
      headerActions: [
        GestureDetector(
          onTap: () async {
            await formController.submit();
          },
          child: Container(
            padding: const EdgeInsets.all(AppSizes.s),
            decoration: BoxDecoration(
              color: Theme.of(context).extension<AppColorExtension>()!.neutralBackground,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
            ),
            child: Icon(
              Symbols.check_rounded,
              size: AppSizes.iconL,
              color: Theme.of(context).extension<AppColorExtension>()!.primaryActive,
            ),
          ),
        ),
      ],
      body: AddEditTransferForm(
        controller: formController,
        initialTransfer: transfer,
        onSubmit: (data) async {
          final provider = context.read<MoneyTransferProvider>();
          final success = await provider.updateTransfer(
            id: transfer.id,
            fromWalletId: data.fromWalletId,
            toWalletId: data.toWalletId,
            amount: data.amount,
            transferDate: data.transferDate,
            note: data.note,
          );

          if (!mounted) return;

          if (success) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            AppFlash.success(
              context,
              isVietnamese
                  ? 'Đã cập nhật giao dịch chuyển tiền'
                  : 'Transfer updated',
            );
          } else {
            AppFlash.error(
              context,
              provider.errorMessage ??
                  (isVietnamese
                      ? 'Không thể cập nhật giao dịch'
                      : 'Cannot update transfer'),
            );
          }
        },
      ),
    );
  }

  Future<void> _handleDelete(MoneyTransferModel transfer) async {
    final isVietnamese = _isVietnamese(context);

    final confirm = await AppConfirmDialog.show(
      context: context,
      title: isVietnamese ? 'Xác nhận' : 'Confirmation',
      message: isVietnamese
          ? 'Bạn có chắc muốn xoá giao dịch chuyển tiền này?'
          : 'Are you sure you want to delete this transfer?',
      confirmText: context.l10n.delete,
      isDestructive: true,
    );

    if (!confirm) {
      return;
    }

    final provider = context.read<MoneyTransferProvider>();
    final success = await provider.deleteTransfer(transfer.id);

    if (!mounted) return;

    if (success) {
      AppFlash.success(
        context,
        isVietnamese ? 'Đã xoá giao dịch chuyển tiền' : 'Transfer deleted',
      );
    } else {
      AppFlash.error(
        context,
        provider.errorMessage ??
            (isVietnamese ? 'Xoá thất bại' : 'Delete failed'),
      );
    }
  }

  bool _isVietnamese(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'vi';
  }
}
