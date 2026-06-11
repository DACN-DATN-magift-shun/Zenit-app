import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
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
import 'package:zenit/features/loans/forms/add_edit_loan_form.dart';
import 'package:zenit/features/loans/models/loan_model.dart';
import 'package:zenit/features/loans/providers/loans_provider.dart';
import 'package:zenit/features/loans/widgets/loan_list_item.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  static const double _cardRadius = 24;
  
  static const int _pageSize = 10;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoansProvider>().loadLoans();
    });
  }

  @override
  void dispose() {
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVietnamese = _isVietnamese(context);
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return BaseLayout(
      appBar: CommonAppBar(
        title: isVietnamese ? 'Quản lý công nợ' : 'Loans and Debts',
        showReturnIcon: true,
        onBack: () => Navigator.pop(context),
      ),
      child: Consumer<LoansProvider>(
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
                  _buildSummary(context, provider),
                  const SizedBox(height: AppSizes.l),
                  _buildToolbar(context, provider),
                  const SizedBox(height: AppSizes.m),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: provider.refreshLoans,
                      child: provider.loans.isEmpty
                          ? _buildEmptyState(context)
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 96),
                              itemCount: (() {
                                final total = provider.loans.length;
                                final totalPages =
                                    (total + _pageSize - 1) ~/ _pageSize;
                                final current = _currentPage.clamp(
                                  1,
                                  totalPages == 0 ? 1 : totalPages,
                                );
                                final start = (current - 1) * _pageSize;
                                final remaining = total - start;
                                final visible = remaining < 0
                                    ? 0
                                    : (remaining < _pageSize ? remaining : _pageSize);
                                return visible + (visible > 0 ? 1 : 0);
                              })(),
                              itemBuilder: (context, index) {
                                final total = provider.loans.length;
                                final totalPages =
                                    (total + _pageSize - 1) ~/ _pageSize;
                                final current = _currentPage.clamp(
                                  1,
                                  totalPages == 0 ? 1 : totalPages,
                                );
                                final start = (current - 1) * _pageSize;
                                final remaining = total - start;
                                final visible = remaining < 0
                                    ? 0
                                    : (remaining < _pageSize ? remaining : _pageSize);
                                if (index == visible) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: AppSizes.s),
                                    child: _buildPaginationSectionForLoans(
                                      colors,
                                      provider.loans.length,
                                    ),
                                  );
                                }
                                final item = provider.loans[start + index];
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
                                  child: LoanListItem(
                                    loan: item,
                                    onTap: () => _openEditLoanDrawer(item),
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
                bottom: AppSizes.l + (AppSizes.m * 5),
                child: FloatingActionButton(
                  onPressed: _showAddLoanDrawer,
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

  Widget _buildErrorState(BuildContext context, LoansProvider provider) {
    final isVietnamese = _isVietnamese(context);

    return Center(
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.errorContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
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
                onPressed: provider.loadLoans,
                child: Text(isVietnamese ? 'Thử lại' : 'Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, LoansProvider provider) {
    final isVietnamese = _isVietnamese(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                title: isVietnamese ? 'Cho vay' : 'Loans',
                amount: provider.totalLoanAmount,
                type: 0,
              ),
            ),
            const SizedBox(width: AppSizes.m),
            Expanded(
              child: _buildSummaryCard(
                context,
                title: isVietnamese ? 'Đi vay' : 'Debts',
                amount: provider.totalDebtAmount,
                type: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.m),
        _buildNetBalanceCard(context, provider.netBalance),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required int amount,
    required int type,
  }) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final isVietnamese = _isVietnamese(context);
    final formatter = NumberFormat.currency(
      locale: isVietnamese ? 'vi_VN' : 'en_US',
      symbol: isVietnamese ? 'đ' : 'VND ',
      decimalDigits: 0,
    );

    final isLoan = type == 0;
    final bgColor = isLoan ? colors.successBackground : colors.errorBackground;
    final textColor = isLoan ? colors.successText : colors.errorText;

    return Container(
      padding: const EdgeInsets.all(AppSizes.l),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.s),
          Text(
            formatter.format(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetBalanceCard(BuildContext context, int netBalance) {
    final isVietnamese = _isVietnamese(context);
    final formatter = NumberFormat.currency(
      locale: isVietnamese ? 'vi_VN' : 'en_US',
      symbol: isVietnamese ? 'đ' : 'VND ',
      decimalDigits: 0,
    );

    final isPositive = netBalance >= 0;
    final amountColor = isPositive
        ? Theme.of(context).colorScheme.onSecondaryContainer
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s),
      child: Center(
        child: Text(
          '${isVietnamese ? 'Chênh lệch' : 'Net balance'}: ${formatter.format(netBalance)}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: amountColor.withValues(alpha: 0.72),
            fontWeight: FontWeight.w500,
            fontFamily: 'GoogleSansFlex',
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, LoansProvider provider) {
    final isVietnamese = _isVietnamese(context);
    final selectedType = provider.selectedTypeFilter;
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    const activeChipColor = Color(0xFFD2E4FF);

    return Column(
      children: [
        const SizedBox.shrink(),
        const SizedBox(height: AppSizes.m),
        Row(
          children: [
            ChoiceChip(
              label: Text(isVietnamese ? 'Tất cả' : 'All'),
              selected: selectedType == null,
              onSelected: (_) => provider.setTypeFilter(null),
              side: BorderSide(
                color: colors.neutralBorder.withValues(alpha: 0.72),
                width: 1,
              ),
              shape: const StadiumBorder(),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerLowest,
              selectedColor: activeChipColor,
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: selectedType == null
                    ? colors.neutralTextPrimary
                    : colors.neutralTextPrimary,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            const SizedBox(width: AppSizes.m),
            ChoiceChip(
              label: Text(isVietnamese ? 'Cho vay' : 'Loans'),
              selected: selectedType == 0,
              onSelected: (_) => provider.setTypeFilter(0),
              side: BorderSide(
                color: colors.neutralBorder.withValues(alpha: 0.72),
                width: 1,
              ),
              shape: const StadiumBorder(),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerLowest,
              selectedColor: activeChipColor,
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: selectedType == 0
                    ? colors.neutralTextPrimary
                    : colors.neutralTextPrimary,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            const SizedBox(width: AppSizes.m),
            ChoiceChip(
              label: Text(isVietnamese ? 'Đi vay' : 'Debts'),
              selected: selectedType == 1,
              onSelected: (_) => provider.setTypeFilter(1),
              side: BorderSide(
                color: colors.neutralBorder.withValues(alpha: 0.72),
                width: 1,
              ),
              shape: const StadiumBorder(),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerLowest,
              selectedColor: activeChipColor,
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: selectedType == 1
                    ? colors.neutralTextPrimary
                    : colors.neutralTextPrimary,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaginationSectionForLoans(
    AppColorExtension colors,
    int totalItems,
  ) {
    final totalPages = totalItems == 0
        ? 1
        : (totalItems + _pageSize - 1) ~/ _pageSize;
    final current = _currentPage.clamp(1, totalPages);
    final pageStart = totalItems == 0 ? 0 : ((current - 1) * _pageSize) + 1;
    final visible = totalItems == 0
        ? 0
        : ((pageStart + _pageSize - 1) > totalItems
              ? (totalItems - pageStart + 1)
              : _pageSize);
    final pageEnd = visible == 0 ? 0 : pageStart + visible - 1;
    final progress = totalPages <= 1 ? 1.0 : current / totalPages;

    final canPrev = current > 1;
    final canNext = current < totalPages;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.m),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.m,
        vertical: AppSizes.s,
      ),
      decoration: BoxDecoration(
        color: colors.neutralSurface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
        border: Border.all(color: colors.neutralBorder.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _textByLocale(
                    vi: 'Trang $current/$totalPages — Hiển thị $pageStart-$pageEnd/$totalItems',
                    en: 'Page $current/$totalPages — Showing $pageStart-$pageEnd/$totalItems',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.neutralTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: canPrev
                        ? () {
                            setState(() {
                              _currentPage = (_currentPage - 1).clamp(
                                1,
                                totalPages,
                              );
                            });
                          }
                        : null,
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      size: AppSizes.iconM,
                    ),
                    color: canPrev
                        ? colors.primaryMain
                        : colors.neutralTextDisable,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSizes.s),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.s,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryMain.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$current / $totalPages',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.primaryMain,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: canNext
                        ? () {
                            setState(() {
                              _currentPage = (_currentPage + 1).clamp(
                                1,
                                totalPages,
                              );
                            });
                          }
                        : null,
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      size: AppSizes.iconM,
                    ),
                    color: canNext
                        ? colors.primaryMain
                        : colors.neutralTextDisable,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s),
          SizedBox(
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: colors.neutralBorder.withValues(alpha: 0.35),
                valueColor: AlwaysStoppedAnimation<Color>(colors.primaryMain),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isVietnamese = _isVietnamese(context);
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 40,
            color: colors.neutralTextSecondary,
          ),
          const SizedBox(height: AppSizes.s),
          Text(
            isVietnamese ? 'Chưa có khoản vay/nợ nào' : 'No loans or debts yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.neutralTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLoanDrawer() {
    final isVietnamese = _isVietnamese(context);
    final formController = AddEditLoanFormController();

    AppDrawer.showAsBottomSheet(
      context: context,
      title: isVietnamese ? 'Thêm khoản vay/nợ' : 'Add loan/debt',
      showDragHandle: true,
      headerActions: [
        GestureDetector(
          onTap: () async {
            await formController.submit();
          },
          child: Container(
            padding: const EdgeInsets.all(AppSizes.s),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).extension<AppColorExtension>()!.neutralBackground,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
            ),
            child: Icon(
              Symbols.check_rounded,
              size: AppSizes.iconL,
              color: Theme.of(
                context,
              ).extension<AppColorExtension>()!.primaryActive,
            ),
          ),
        ),
      ],
      body: AddEditLoanForm(
        controller: formController,
        onSubmit: (data) async {
          final provider = context.read<LoansProvider>();
          final success = await provider.addLoan(
            name: data.name,
            type: data.type,
            status: data.status,
            amount: data.amount,
            date: data.date,
            dueDate: data.dueDate,
            note: data.note,
          );

          if (!mounted) return;

          if (success) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            AppFlash.success(
              context,
              isVietnamese ? 'Đã thêm khoản vay/nợ' : 'Loan/debt added',
            );
          } else {
            AppFlash.error(
              context,
              provider.errorMessage ??
                  (isVietnamese
                      ? 'Không thể thêm khoản vay/nợ'
                      : 'Cannot add loan/debt'),
            );
          }
        },
      ),
    );
  }

  void _openEditLoanDrawer(LoanModel loan) {
    final isVietnamese = _isVietnamese(context);
    final formController = AddEditLoanFormController();

    AppDrawer.showAsBottomSheet(
      context: context,
      title: isVietnamese ? 'Cập nhật khoản vay/nợ' : 'Update loan/debt',
      showDragHandle: true,
      headerActions: [
        GestureDetector(
          onTap: () async {
            await formController.submit();
          },
          child: Container(
            padding: const EdgeInsets.all(AppSizes.s),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).extension<AppColorExtension>()!.neutralBackground,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
            ),
            child: Icon(
              Symbols.check_rounded,
              size: AppSizes.iconL,
              color: Theme.of(
                context,
              ).extension<AppColorExtension>()!.primaryActive,
            ),
          ),
        ),
      ],
      body: AddEditLoanForm(
        controller: formController,
        initialLoan: loan,
        onSubmit: (data) async {
          final provider = context.read<LoansProvider>();
          final success = await provider.updateLoan(
            id: loan.id,
            name: data.name,
            type: data.type,
            status: data.status,
            amount: data.amount,
            date: data.date,
            dueDate: data.dueDate,
            note: data.note,
          );

          if (!mounted) return;

          if (success) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            AppFlash.success(
              context,
              isVietnamese ? 'Đã cập nhật khoản vay/nợ' : 'Loan/debt updated',
            );
          } else {
            AppFlash.error(
              context,
              provider.errorMessage ??
                  (isVietnamese
                      ? 'Không thể cập nhật khoản vay/nợ'
                      : 'Cannot update loan/debt'),
            );
          }
        },
      ),
    );
  }

  Future<void> _handleDelete(LoanModel loan) async {
    final isVietnamese = _isVietnamese(context);

    final confirm = await AppConfirmDialog.show(
      context: context,
      title: isVietnamese ? 'Xác nhận' : 'Confirmation',
      message: isVietnamese
          ? 'Bạn có chắc muốn xoá khoản này không?'
          : 'Are you sure you want to delete this item?',
      confirmText: context.l10n.delete,
      isDestructive: true,
    );

    if (!confirm) {
      return;
    }

    if (!mounted) return;

    final provider = context.read<LoansProvider>();
    final success = await provider.deleteLoan(loan.id);

    if (!mounted) return;

    if (success) {
      AppFlash.success(
        context,
        isVietnamese ? 'Đã xoá khoản vay/nợ' : 'Loan/debt deleted',
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

  String _textByLocale({required String vi, required String en}) {
    return _isVietnamese(context) ? vi : en;
  }
}
