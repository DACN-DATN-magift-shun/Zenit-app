import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/services/auth_service.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_flash.dart';
import 'package:zenit/core/widgets/app_drawer.dart';
import 'package:zenit/features/history/form/view_edit_tran_form.dart';
import 'package:zenit/features/transaction/models/transaction_model.dart';
import 'package:zenit/features/transaction/services/transaction_service.dart';
import 'package:zenit/features/main/widgets/history/transaction_item.dart';

class HistoryContent extends StatefulWidget {
  const HistoryContent({super.key});

  @override
  State<HistoryContent> createState() => _HistoryContentState();
}

class _HistoryContentState extends State<HistoryContent> {
  final TransactionService _transactionService = TransactionService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isAuthenticated = false;
  String? _errorMessage;
  int _totalItems = 0;

  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initializeScreen() async {
    setState(() => _isLoading = true);

    final isAuth = await _authService.isAuthenticated();

    if (!mounted) {
      return;
    }

    _isAuthenticated = isAuth;

    if (!isAuth) {
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    await _loadTransactions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isAuthenticated) {
      return;
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _transactionService.getAllTransactions(
        pageSize: _pageSize,
      );

      setState(() {
        _transactions = response.items;
        _totalItems = response.meta.totalItems;
        _hasMore = _transactions.length < _totalItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoading || !_hasMore || _transactions.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the last transaction's id as beforeId for cursor-based pagination
      final lastId = _transactions.last.id;

      final response = await _transactionService.getAllTransactions(
        pageSize: _pageSize,
        beforeId: lastId,
      );

      setState(() {
        _transactions.addAll(response.items);
        _hasMore = _transactions.length < _totalItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshTransactions() async {
    if (!_isAuthenticated) {
      return;
    }

    setState(() {
      _transactions = [];
      _hasMore = true;
    });
    await _loadTransactions();
  }

  Future<void> _deleteTransaction(TransactionModel transaction) async {
    if (transaction.id == null) return;

    try {
      final success = await _transactionService.deleteTransaction(
        transaction.id!,
      );
      if (success) {
        setState(() {
          _transactions.removeWhere((t) => t.id == transaction.id);
          _totalItems--;
        });

        if (mounted) {
          AppFlash.success(
            context,
            context.l10n.deleteTransactionSuccess(transaction.title),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppFlash.error(context, context.l10n.genericErrorWithReason(e.toString()));
      }
    }
  }

  Future<void> _openTransactionDetail(TransactionModel transaction) async {
    final transactionId = transaction.id;
    if (transactionId == null || transactionId.isEmpty) {
      if (mounted) {
        AppFlash.error(context, context.l10n.transactionIdNotFound);
      }
      return;
    }

    final formController = ViewEditTranFormController();

    try {
      await AppDrawer.showAsBottomSheet(
        context: context,
        title: context.l10n.transactionDetail,
        showCloseButton: false,
        showDragHandle: true,
        headerActions: [
          AnimatedBuilder(
            animation: Listenable.merge([
              formController.isEditing,
              formController.isSaving,
            ]),
            builder: (context, _) {
              final colors = Theme.of(context).extension<AppColorExtension>()!;
              final isEditing = formController.isEditing.value;
              final isSaving = formController.isSaving.value;

              Widget buildActionButton({
                required VoidCallback? onTap,
                required Color iconColor,
                required IconData icon,
                Color? backgroundColor,
                Widget? child,
              }) {
                return GestureDetector(
                  onTap: onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(AppSizes.s),
                    decoration: BoxDecoration(
                      color: backgroundColor ?? colors.neutralBackground,
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadiusLarge,
                      ),
                    ),
                    child:
                        child ??
                        Icon(icon, size: AppSizes.iconL, color: iconColor),
                  ),
                );
              }

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isEditing) ...[
                    buildActionButton(
                      onTap: isSaving ? null : formController.cancelEditing,
                      icon: Symbols.close_rounded,
                      iconColor: colors.errorIcon,
                      backgroundColor: colors.errorBackground,
                    ),
                    const SizedBox(width: AppSizes.s),
                  ],
                  buildActionButton(
                    onTap: isSaving
                        ? null
                        : () async {
                            if (isEditing) {
                              await formController.saveChanges();
                            } else {
                              await formController.startEditing();
                            }
                          },
                    icon: isEditing
                        ? Symbols.check_rounded
                        : Symbols.edit_rounded,
                    iconColor: colors.primaryActive,
                    child: isSaving
                        ? SizedBox(
                            width: AppSizes.iconM,
                            height: AppSizes.iconM,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.primaryActive,
                            ),
                          )
                        : null,
                  ),
                ],
              );
            },
          ),
        ],
        body: ViewEditTranForm(
          transactionId: transactionId,
          controller: formController,
          onTransactionUpdated: _refreshTransactions,
        ),
      );
    } finally {
      formController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final l10n = context.l10n;

    return Scaffold(
      appBar: CommonAppBar(title: l10n.history, showSecondaryText: false),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(AppColorExtension colors) {
    // Wrap everything in RefreshIndicator to allow pull-to-refresh in all states
    return RefreshIndicator(
      onRefresh: _refreshTransactions,
      child: _buildContent(colors),
    );
  }

  Widget _buildContent(AppColorExtension colors) {
    if (!_isAuthenticated) {
      return _buildUnauthenticatedView(colors);
    }

    if (_errorMessage != null && _transactions.isEmpty) {
      return _buildErrorView(colors);
    }

    if (!_isLoading && _transactions.isEmpty) {
      return _buildEmptyView(colors);
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppSizes.m),
      itemCount: _transactions.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _transactions.length) {
          return _buildLoadingIndicator();
        }

        final transaction = _transactions[index];
        return TransactionItem(
          transaction: transaction,
          onTap: () => _openTransactionDetail(transaction),
          onDelete: () => _deleteTransaction(transaction),
        );
      },
    );
  }

  Widget _buildErrorView(AppColorExtension colors) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.l),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: colors.errorIcon),
                const SizedBox(height: AppSizes.m),
                Text(
                  l10n.errorOccurred,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSizes.s),
                Text(
                  _errorMessage ?? '',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.neutralTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.l),
                ElevatedButton(
                  onPressed: _loadTransactions,
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView(AppColorExtension colors) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: colors.neutralTextSecondary,
              ),
              const SizedBox(height: AppSizes.m),
              Text(
                l10n.noTransactions,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.neutralTextSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.s),
              Text(
                l10n.pullToRefresh,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.neutralTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(AppSizes.l),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildUnauthenticatedView(AppColorExtension colors) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: colors.neutralTextSecondary),
              const SizedBox(height: AppSizes.m),
              Text(
                l10n.needLoginHistory,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.neutralTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
