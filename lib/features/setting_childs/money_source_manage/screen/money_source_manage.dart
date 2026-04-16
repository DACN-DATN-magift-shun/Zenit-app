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
import 'package:zenit/features/setting_childs/money_source_manage/forms/add_edit_money_source_form.dart';
import 'package:zenit/features/setting_childs/money_source_manage/forms/view_edit_money_source_form.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';
import 'package:zenit/features/setting_childs/money_source_manage/providers/money_source_provider.dart';
import 'package:zenit/features/setting_childs/money_source_manage/widgets/money_source_list_item.dart';

class MoneySourceManageScreen extends StatefulWidget {
  const MoneySourceManageScreen({super.key});

  @override
  State<MoneySourceManageScreen> createState() =>
      _MoneySourceManageScreenState();
}

class _MoneySourceManageScreenState extends State<MoneySourceManageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoneySourceProvider>().loadAllMoneySources();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      appBar: CommonAppBar(
        title: context.l10n.moneySourceManagement,
        showReturnIcon: true,
        onBack: () => Navigator.pop(context),
      ),
      child: Consumer<MoneySourceProvider>(
        builder: (context, moneySourceProvider, child) {
          if (moneySourceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (moneySourceProvider.errorMessage != null) {
            return _buildErrorState(context, moneySourceProvider);
          }

          return RefreshIndicator(
            onRefresh: moneySourceProvider.refreshMoneySources,
            child: _buildWalletList(context, moneySourceProvider.moneySources),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    MoneySourceProvider moneySourceProvider,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.errorOccurred,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSizes.s),
          Text(
            moneySourceProvider.errorMessage!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSizes.l),
          ElevatedButton(
            onPressed: moneySourceProvider.loadAllMoneySources,
            child: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletList(
    BuildContext context,
    List<MoneySourceModel> sources,
  ) {
    return Stack(
      children: [
        ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSizes.l,
            AppSizes.m,
            AppSizes.l,
            96,
          ),
          children: [
            if (sources.isEmpty)
              _buildEmptyState(context)
            else
              ...List.generate(sources.length, (index) {
                final source = sources[index];
                final animationDelayMs = index < 8 ? index * 40 : 320;

                return Animate(
                  delay: Duration(milliseconds: animationDelayMs),
                  effects: [
                    FadeEffect(duration: 280.ms, curve: Curves.easeOut),
                    SlideEffect(
                      begin: const Offset(0, 0.08),
                      end: const Offset(0, 0),
                      duration: 340.ms,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: MoneySourceListItem(
                    moneySource: source,
                    onTap: () => _openMoneySourceDetail(source),
                    onDelete: () => _handleDelete(source),
                  ),
                );
              }),
          ],
        ),
        Positioned(
          right: AppSizes.l,
          bottom: AppSizes.l,
          child: FloatingActionButton(
            onPressed: _showAddMoneySourceDrawer,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 30, weight: 900, fill: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isVietnamese = _isVietnamese(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.xl),
      child: Center(
        child: Text(
          isVietnamese ? 'Chưa có nguồn tiền nào' : 'No wallets yet',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Future<void> _openMoneySourceDetail(MoneySourceModel source) async {
    if (source.id.trim().isEmpty) {
      AppFlash.error(
        context,
        _isVietnamese(context)
            ? 'Không tìm thấy id ví để xem chi tiết.'
            : 'Wallet id is missing, cannot open detail.',
      );
      return;
    }

    final isEditing = ValueNotifier<bool>(false);

    try {
      await AppDrawer.showAsBottomSheet(
        context: context,
        title: _isVietnamese(context) ? 'Chi tiết nguồn tiền' : 'Wallet detail',
        showDragHandle: true,
        headerActions: [
          ValueListenableBuilder<bool>(
            valueListenable: isEditing,
            builder: (context, editing, _) {
              if (editing) {
                return const SizedBox.shrink();
              }

              final colors = Theme.of(context).extension<AppColorExtension>()!;
              return GestureDetector(
                onTap: () => isEditing.value = !editing,
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.s),
                  decoration: BoxDecoration(
                    color: colors.neutralBackground,
                    borderRadius: BorderRadius.circular(
                      AppSizes.borderRadiusLarge,
                    ),
                  ),
                  child: Icon(
                    Symbols.edit_rounded,
                    size: AppSizes.iconL,
                    color: colors.primaryActive,
                  ),
                ),
              );
            },
          ),
        ],
        body: ViewEditMoneySourceForm(
          moneySourceId: source.id,
          isEditing: isEditing,
          onUpdated: () async {
            await context.read<MoneySourceProvider>().refreshMoneySources();
          },
        ),
      );
    } finally {
      isEditing.dispose();
    }
  }

  void _showAddMoneySourceDrawer() {
    AppDrawer.showAsBottomSheet(
      context: context,
      title: _isVietnamese(context) ? 'Thêm nguồn tiền' : 'Add money source',
      showDragHandle: true,
      body: AddEditMoneySourceForm(
        onSubmit: (data) async {
          final moneySourceProvider = context.read<MoneySourceProvider>();
          try {
            final success = await moneySourceProvider.addMoneySource(
              name: data.name,
              icon: data.iconName,
              amount: data.amount,
              note: data.note,
              isIncludeInTotalBalance: data.isIncludeInTotalBalance,
            );

            if (!mounted) return;

            if (success) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                AppFlash.success(
                  context,
                  _isVietnamese(context)
                      ? 'Đã thêm nguồn tiền: ${data.name}'
                      : 'Money source added: ${data.name}',
                );
              });
            } else {
              AppFlash.error(
                context,
                moneySourceProvider.errorMessage ?? context.l10n.deleteFailed,
              );
            }
          } catch (e) {
            if (!mounted) return;
            AppFlash.error(context, e.toString());
          }
        },
      ),
    );
  }

  Future<void> _handleDelete(MoneySourceModel source) async {
    final confirm = await AppConfirmDialog.show(
      context: context,
      title: context.l10n.confirmAction,
      message: _isVietnamese(context)
          ? 'Bạn có chắc muốn xóa nguồn tiền này?'
          : 'Are you sure you want to delete this money source?',
      confirmText: context.l10n.delete,
      isDestructive: true,
    );

    if (!confirm) {
      return;
    }

    final moneySourceProvider = context.read<MoneySourceProvider>();
    final success = await moneySourceProvider.deleteMoneySource(source.id);

    if (!mounted) return;

    if (success) {
      AppFlash.success(
        context,
        _isVietnamese(context) ? 'Đã xóa nguồn tiền' : 'Money source deleted',
      );
    } else {
      AppFlash.error(
        context,
        moneySourceProvider.errorMessage ?? context.l10n.deleteFailed,
      );
    }
  }

  bool _isVietnamese(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'vi';
  }
}
