import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/layout/main_layout.dart';
import 'package:zenit/core/services/auth_service.dart';
import 'package:zenit/core/theme/app_colors.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/widgets/app_flash.dart';
import 'package:zenit/core/widgets/app_drawer.dart';
import 'package:zenit/features/transaction/forms/add_transaction_form.dart';
import 'package:zenit/features/transaction/models/transaction_model.dart';
import 'package:zenit/features/transaction/services/transaction_service.dart';
import 'package:zenit/features/main/models/action_item.dart';
import 'package:zenit/features/main/models/home_action_item.dart';
import 'package:zenit/features/main/widgets/home/home_action_grid.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final AuthService _authService = AuthService();
  final TransactionService _transactionService = TransactionService();
  static const int _recentTransactionsLimit = 3;
  
  String _userName = '';
  bool _isAuthenticated = false;
  bool _isLoading = true;
  bool _isLoadingRecentTransactions = false;
  String? _recentTransactionsError;
  List<TransactionModel> _recentTransactions = [];

  List<HomeActionItem> _buildActionItems(BuildContext context) {
    final l10n = context.l10n;

    return [
      HomeActionItem(
        title: l10n.actionTransaction,
        icon: Icons.swap_horiz_rounded,
        backgroundColor: AppColors.light.secondaryMain,
        iconColor: AppColors.light.primaryMain,
        type: ActionType.transaction,
      ),
      HomeActionItem(
        title: l10n.actionQuickImport,
        icon: Icons.library_add_rounded,
        backgroundColor: AppColors.light.primaryMain,
        iconColor: Colors.white,
        type: ActionType.quickImport,
        useGradient: true,
        gradientColors: [
          AppColors.light.primaryMain,
          AppColors.light.primaryActive,
        ],
      ),
      HomeActionItem(
        title: l10n.actionGoals,
        icon: Icons.flag_rounded,
        backgroundColor: AppColors.light.secondaryMain,
        iconColor: AppColors.light.primaryMain,
        type: ActionType.goals,
      ),
      HomeActionItem(
        title: l10n.actionMoreActions,
        icon: Icons.apps_rounded,
        backgroundColor: AppColors.light.primaryMain,
        iconColor: Colors.white,
        type: ActionType.moreActions,
        useGradient: true,
        gradientColors: [
          AppColors.light.primaryMain,
          AppColors.light.primaryActive,
        ],
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);
    
    final isAuth = await _authService.isAuthenticated();

    if (!mounted) return;

    setState(() {
      _isAuthenticated = isAuth;
      _isLoading = false;
      if (!isAuth) {
        _userName = '';
      }
    });

    if (!isAuth) {
      setState(() {
        _recentTransactions = [];
        _recentTransactionsError = null;
      });
      return;
    }

    _loadRecentTransactions();

    final response = await _authService.getUserInfo();

    if (!mounted) return;
    
    if (response != null && response.statusCode == 200) {
      final rawData = response.data;
      final data = rawData is Map<String, dynamic>
          ? rawData
          : rawData is Map
              ? Map<String, dynamic>.from(rawData)
              : <String, dynamic>{};
      final userData = data['data'] is Map
          ? Map<String, dynamic>.from(data['data'] as Map)
          : data;

      setState(() {
        _userName = userData['username']?.toString().trim().isNotEmpty == true
            ? userData['username'].toString()
            : 'User';
      });
    }
  }

  Future<void> _loadRecentTransactions({bool showLoading = true}) async {
    if (!_isAuthenticated) {
      setState(() {
        _recentTransactions = [];
        _recentTransactionsError = null;
        _isLoadingRecentTransactions = false;
      });
      return;
    }

    if (showLoading) {
      setState(() {
        _isLoadingRecentTransactions = true;
        _recentTransactionsError = null;
      });
    } else {
      setState(() {
        _recentTransactionsError = null;
      });
    }

    try {
      final response = await _transactionService.getAllTransactions(
        pageSize: _recentTransactionsLimit,
        useCountTotal: false,
      );

      if (!mounted) return;

      final sortedItems = [...response.items]
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      setState(() {
        _recentTransactions = sortedItems.take(_recentTransactionsLimit).toList();
        _isLoadingRecentTransactions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _recentTransactionsError = e.toString();
        _isLoadingRecentTransactions = false;
      });
    }
  }

  void _prependRecentTransaction(TransactionModel transaction) {
    setState(() {
      final merged = [
        transaction,
        ..._recentTransactions.where((item) => item.id != transaction.id),
      ]..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      _recentTransactions = merged.take(_recentTransactionsLimit).toList();
    });
  }

  /// Handle action item tap using switch-case
  void _handleActionTap(HomeActionItem item) {
    switch (item.type) {
      case ActionType.transaction:
        _navigateToTransaction();
        break;
      case ActionType.quickImport:
        _navigateToQuickImport();
        break;
      case ActionType.goals:
        _navigateToGoals();
        break;
      case ActionType.moreActions:
        _showMoreActions();
        break;
    }
  }

  // Navigation methods - implement actual navigation logic here
  void _navigateToTransaction() {
    TransactionFormData? Function()? getFormData;
    
    AppDrawer.showAsBottomSheet(
      context: context,
      title: context.l10n.addTransaction,
      showCloseButton: false,
      showDragHandle: true,
      headerActions: [
        IconButton(
          onPressed: () => _handleCreateTransaction(getFormData),
          icon: Icon(
            Icons.check_circle_outline_rounded,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
        ),
      ],
      body: AddTransactionForm(
        onFormReady: (getData) {
          getFormData = getData;
        },
      ),
    );
  }

  /// Business logic: Tạo transaction mới
  Future<void> _handleCreateTransaction(
    TransactionFormData? Function()? getFormData,
  ) async {
    if (getFormData == null) return;

    final formData = getFormData();
    if (formData == null) return; // Validation failed

    try {
      final createdTransaction = await _transactionService.createTransaction(
        title: formData.title,
        note: formData.note,
        amount: formData.amount,
        transactionDate: formData.transactionDate,
        categoryId: formData.categoryId,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close drawer
        _prependRecentTransaction(createdTransaction);
        _loadRecentTransactions(showLoading: false);
        AppFlash.success(context, context.l10n.transactionAddedSuccess);
      }
    } catch (e) {
      if (mounted) {
        AppFlash.error(context, context.l10n.genericErrorWithReason(e.toString()));
      }
    }
  }


  void _navigateToQuickImport() {
    // TODO: Navigate to Quick Import screen
    AppFlash.info(context, context.l10n.navigateQuickImport);
  }

  void _navigateToGoals() {
    // TODO: Navigate to Goals screen
    AppFlash.info(context, context.l10n.navigateGoals);
  }
  void _showMoreActions() {
    // TODO: Show more actions bottom sheet or screen
    AppFlash.info(context, context.l10n.showMoreActions);
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatTransactionDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildRecentTransactionsSection(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.l),
      decoration: BoxDecoration(
        color: AppColors.light.neutralBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
        border: Border.all(
          color: AppColors.light.neutralBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recentTransactionsTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.light.neutralTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.m),
          if (!_isAuthenticated)
            Text(
              l10n.needLoginHistory,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.light.neutralTextSecondary,
              ),
            )
          else if (_isLoadingRecentTransactions)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.l),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_recentTransactionsError != null && _recentTransactions.isEmpty)
            Text(
              l10n.cannotLoadData,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.light.errorText,
              ),
            )
          else if (_recentTransactions.isEmpty)
            Text(
              l10n.noTransactions,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.light.neutralTextSecondary,
              ),
            )
          else
            Column(
              children: List.generate(_recentTransactions.length, (index) {
                final item = _recentTransactions[index];
                final categoryName = item.category?.name ?? l10n.unknown;

                return Container(
                  margin: EdgeInsets.only(
                    bottom: index == _recentTransactions.length - 1 ? 0 : AppSizes.m,
                  ),
                  padding: const EdgeInsets.all(AppSizes.m),
                  decoration: BoxDecoration(
                    color: AppColors.light.secondaryMain,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.light.neutralTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSizes.xs),
                            Text(
                              '$categoryName • ${_formatTransactionDate(item.transactionDate)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.light.neutralTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSizes.s),
                      Text(
                        _formatCurrency(item.amount),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.light.neutralTextPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MainLayout(
      appBar: CommonAppBar(
        title: _isAuthenticated 
            ? l10n.welcomeBackUser(_userName)
            : l10n.homeGuestTitle,
        showSecondaryText: _isAuthenticated,
        secondaryText: _isAuthenticated ? l10n.haveNiceDay : null,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.l),
            // Action Grid Section
            HomeActionGrid(
              items: _buildActionItems(context),
              onItemTap: _handleActionTap,
            ),
            const SizedBox(height: AppSizes.l),
            _buildRecentTransactionsSection(context),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}
