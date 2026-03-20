import 'dart:async';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/services/auth_service.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_flash.dart';
import 'package:zenit/core/widgets/app_drawer.dart';
import 'package:zenit/features/history/form/view_edit_tran_form.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';
import 'package:zenit/features/transaction/models/transaction_model.dart';
import 'package:zenit/features/transaction/services/transaction_service.dart';
import 'package:zenit/features/main/widgets/history/transaction_item.dart';

class HistoryContent extends StatefulWidget {
  const HistoryContent({super.key, this.isActive = false});

  final bool isActive;

  @override
  State<HistoryContent> createState() => _HistoryContentState();
}

class _HistoryContentState extends State<HistoryContent> {
  final TransactionService _transactionService = TransactionService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _isCheckingAuth = true;
  String? _errorMessage;
  int _totalItems = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  final Map<int, List<TransactionModel>> _pageCache = {};
  final Map<int, String?> _beforeIdByPage = {1: null};

  DateTime? _fromDate;
  DateTime? _toDate;
  CategoryModel? _selectedCategory;
  String _searchKeyword = '';

  static const int _pageSize = 10;
  late bool _wasActive;

  @override
  void initState() {
    super.initState();
    _wasActive = widget.isActive;
    _initializeScreen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = context.read<CategoryProvider>();
      if (!categoryProvider.hasData) {
        categoryProvider.loadAllCategories();
      }
    });
  }

  @override
  void didUpdateWidget(covariant HistoryContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_wasActive && widget.isActive) {
      _refreshTransactions();
    }

    _wasActive = widget.isActive;
  }

  Future<void> _initializeScreen() async {
    final isAuth = await _authService.isAuthenticated();

    if (!mounted) {
      return;
    }

    setState(() {
      _isAuthenticated = isAuth;
      _isCheckingAuth = false;
      _isLoading = false;
      _errorMessage = null;
    });

    if (!isAuth) {
      return;
    }

    await _goToFirstPage(forceRefresh: true);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  bool get _isVietnamese {
    return Localizations.localeOf(context).languageCode == 'vi';
  }

  String _textByLocale({required String vi, required String en}) {
    return _isVietnamese ? vi : en;
  }

  DateTime? get _fromDateForApi {
    if (_fromDate == null) {
      return null;
    }

    return DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);
  }

  DateTime? get _toDateForApi {
    if (_toDate == null) {
      return null;
    }

    return DateTime(
      _toDate!.year,
      _toDate!.month,
      _toDate!.day,
      23,
      59,
      59,
      999,
    );
  }

  bool get _hasActiveFilters {
    return _searchKeyword.isNotEmpty ||
        _selectedCategory != null ||
        _fromDate != null ||
        _toDate != null;
  }

  bool get _canGoPrevious {
    return !_isLoading && _currentPage > 1;
  }

  bool get _canGoNext {
    return !_isLoading &&
        _currentPage < _totalPages &&
        _transactions.isNotEmpty;
  }

  void _resetPaginationState() {
    _currentPage = 1;
    _totalItems = 0;
    _totalPages = 1;
    _transactions = [];
    _pageCache.clear();
    _beforeIdByPage
      ..clear()
      ..[1] = null;
  }

  Future<void> _loadTransactions({
    required int page,
    bool forceRefresh = false,
  }) async {
    if (_isCheckingAuth || !_isAuthenticated || _isLoading) {
      return;
    }

    if (!forceRefresh && _pageCache.containsKey(page)) {
      setState(() {
        _transactions = List<TransactionModel>.from(_pageCache[page]!);
        _currentPage = page;
        _errorMessage = null;
      });
      return;
    }

    if (page > 1 && !_beforeIdByPage.containsKey(page)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _transactionService.getAllTransactions(
        pageSize: _pageSize,
        beforeId: _beforeIdByPage[page],
        fromDate: _fromDateForApi,
        toDate: _toDateForApi,
        categoryId: _selectedCategory?.id,
        search: _searchKeyword.isEmpty ? null : _searchKeyword,
      );

      if (!mounted) {
        return;
      }

      final totalPages = response.meta.pageCount <= 0
          ? 1
          : response.meta.pageCount;

      setState(() {
        _transactions = response.items;
        _pageCache[page] = List<TransactionModel>.from(response.items);
        _currentPage = page;
        _totalItems = response.meta.totalItems;
        _totalPages = totalPages;
        _errorMessage = null;

        if (response.items.isNotEmpty) {
          _beforeIdByPage[page + 1] = response.items.last.id;
        } else {
          _beforeIdByPage.remove(page + 1);
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _goToFirstPage({bool forceRefresh = false}) async {
    if (!_isAuthenticated) {
      return;
    }

    setState(() {
      _resetPaginationState();
    });

    await _loadTransactions(page: 1, forceRefresh: forceRefresh);
  }

  Future<void> _goToPreviousPage() async {
    if (!_canGoPrevious) {
      return;
    }

    final previousPage = _currentPage - 1;
    if (_pageCache.containsKey(previousPage)) {
      setState(() {
        _currentPage = previousPage;
        _transactions = List<TransactionModel>.from(_pageCache[previousPage]!);
        _errorMessage = null;
      });
      return;
    }

    await _loadTransactions(page: previousPage);
  }

  Future<void> _goToNextPage() async {
    if (!_canGoNext) {
      return;
    }

    await _loadTransactions(page: _currentPage + 1);
  }

  Future<void> _refreshTransactions() async {
    if (!_isAuthenticated) {
      return;
    }

    await _goToFirstPage(forceRefresh: true);
  }

  Future<void> _applySearchKeyword(String keyword) async {
    if (!mounted) {
      return;
    }

    final normalizedKeyword = keyword.trim();
    if (_searchKeyword == normalizedKeyword) {
      return;
    }

    setState(() {
      _searchKeyword = normalizedKeyword;
    });

    await _goToFirstPage();
  }

  void _onSearchChanged(String value) {
    setState(() {});

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) {
        return;
      }
      _applySearchKeyword(value);
    });
  }

  Future<void> _clearSearch() async {
    _searchDebounce?.cancel();
    _searchController.clear();
    await _applySearchKeyword('');
  }

  Future<void> _pickFromDate() async {
    final now = DateTime.now();
    final initial = _fromDate ?? _toDate ?? now;
    final lastDate = _toDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(lastDate) ? lastDate : initial,
      firstDate: DateTime(2000),
      lastDate: lastDate,
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _fromDate = DateTime(picked.year, picked.month, picked.day);
      if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
        _toDate = _fromDate;
      }
    });

    await _goToFirstPage();
  }

  Future<void> _pickToDate() async {
    final now = DateTime.now();
    final firstDate = _fromDate ?? DateTime(2000);
    final initial = _toDate ?? _fromDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: firstDate,
      lastDate: now,
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _toDate = DateTime(picked.year, picked.month, picked.day);
    });

    await _goToFirstPage();
  }

  Future<void> _setCategoryFilter(CategoryModel? category) async {
    final isSame = category?.id == _selectedCategory?.id;
    if (isSame) {
      return;
    }

    setState(() {
      _selectedCategory = category;
    });

    await _goToFirstPage();
  }

  Future<void> _showCategoryPicker() async {
    final categoryProvider = context.read<CategoryProvider>();

    if (!categoryProvider.hasData && !categoryProvider.isLoading) {
      await categoryProvider.loadAllCategories();
    }

    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Consumer<CategoryProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && !provider.hasData) {
                return const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final categories = List<CategoryModel>.from(provider.categories)
                ..sort((a, b) => a.name.compareTo(b.name));

              return ListView(
                shrinkWrap: true,
                children: [
                  ListTile(title: Text(context.l10n.category)),
                  ListTile(
                    title: Text(
                      _textByLocale(
                        vi: 'Tất cả danh mục',
                        en: 'All categories',
                      ),
                    ),
                    trailing: _selectedCategory == null
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await _setCategoryFilter(null);
                    },
                  ),
                  ...categories.map((category) {
                    final isSelected = _selectedCategory?.id == category.id;
                    return ListTile(
                      title: Text(category.name),
                      trailing: isSelected ? const Icon(Icons.check) : null,
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        await _setCategoryFilter(category);
                      },
                    );
                  }),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _clearFilters() async {
    _searchDebounce?.cancel();
    _searchController.clear();

    setState(() {
      _searchKeyword = '';
      _selectedCategory = null;
      _fromDate = null;
      _toDate = null;
    });

    await _goToFirstPage();
  }

  Future<void> _deleteTransaction(TransactionModel transaction) async {
    if (transaction.id == null) return;

    try {
      final success = await _transactionService.deleteTransaction(
        transaction.id!,
      );
      if (success) {
        if (mounted) {
          AppFlash.success(
            context,
            context.l10n.deleteTransactionSuccess(transaction.title),
          );
        }

        await _refreshTransactions();
      }
    } catch (e) {
      if (mounted) {
        AppFlash.error(
          context,
          context.l10n.genericErrorWithReason(e.toString()),
        );
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
    if (_isCheckingAuth) {
      return _buildInitialLoadingView();
    }

    if (!_isAuthenticated) {
      return _buildUnauthenticatedView(colors);
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.l,
        AppSizes.m,
        AppSizes.l,
        AppSizes.l,
      ),
      children: [
        _buildFilterSection(colors),
        const SizedBox(height: AppSizes.m),
        if (_errorMessage != null && _transactions.isEmpty)
          _buildInlineErrorView(colors)
        else if (_isLoading && _transactions.isEmpty)
          _buildLoadingIndicator()
        else if (!_isLoading && _transactions.isEmpty)
          _buildInlineEmptyView(colors)
        else ...[
          ...List.generate(_transactions.length, (index) {
            final transaction = _transactions[index];
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
              child: TransactionItem(
                transaction: transaction,
                onTap: () => _openTransactionDetail(transaction),
                onDelete: () => _deleteTransaction(transaction),
              ),
            );
          }),
          if (_isLoading) _buildLoadingIndicator(),
          _buildPaginationSection(colors),
        ],
      ],
    );
  }

  Widget _buildFilterSection(AppColorExtension colors) {
    final categoryLabel = _selectedCategory?.name ?? context.l10n.category;
    final fromLabel = _fromDate == null
        ? context.l10n.fromLabel
        : DateFormat('dd/MM/yyyy').format(_fromDate!);
    final toLabel = _toDate == null
        ? context.l10n.toLabel
        : DateFormat('dd/MM/yyyy').format(_toDate!);

    return Container(
      padding: const EdgeInsets.all(AppSizes.l),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.neutralSurface, colors.secondaryMain],
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        border: Border.all(color: colors.neutralBorder.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: colors.neutralBorder.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.s),
                decoration: BoxDecoration(
                  color: colors.primaryMain.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(
                    AppSizes.borderRadiusXSmall,
                  ),
                ),
                child: Icon(
                  Symbols.tune_rounded,
                  size: AppSizes.iconS,
                  color: colors.primaryMain,
                ),
              ),
              const SizedBox(width: AppSizes.m),
              Expanded(
                child: Text(
                  _textByLocale(
                    vi: 'Tìm kiếm và lọc giao dịch',
                    en: 'Search and filter transactions',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.m,
                  vertical: AppSizes.s,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryMain.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                // child: Text(
                //   '$_pageSize / page',
                //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                //     color: colors.primaryMain,
                //     fontWeight: FontWeight.w700,
                //   ),
                // ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.l),
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onSubmitted: (value) async {
              await _applySearchKeyword(value);
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.neutralBackground,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                borderSide: BorderSide(color: colors.neutralBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                borderSide: BorderSide(color: colors.primaryMain, width: 1.6),
              ),
              hintText: _textByLocale(
                vi: 'Tìm giao dịch',
                en: 'Search transactions',
              ),
              prefixIcon: Icon(
                Symbols.search_rounded,
                color: colors.primaryMain,
              ),
              suffixIcon: _searchController.text.trim().isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearSearch,
                      icon: Icon(
                        Icons.close_rounded,
                        color: colors.neutralTextSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSizes.l),
          Wrap(
            spacing: AppSizes.m,
            runSpacing: AppSizes.m,
            children: [
              _buildFilterButton(
                label: categoryLabel,
                icon: Symbols.category_rounded,
                isActive: _selectedCategory != null,
                onTap: _showCategoryPicker,
              ),
              _buildFilterButton(
                label: fromLabel,
                icon: Symbols.calendar_month_rounded,
                isActive: _fromDate != null,
                onTap: _pickFromDate,
              ),
              _buildFilterButton(
                label: toLabel,
                icon: Symbols.event_rounded,
                isActive: _toDate != null,
                onTap: _pickToDate,
              ),
              if (_hasActiveFilters)
                _buildFilterButton(
                  label: _textByLocale(vi: 'Xóa lọc', en: 'Clear filters'),
                  icon: Symbols.refresh_rounded,
                  isActive: true,
                  onTap: _clearFilters,
                  isDanger: true,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required Future<void> Function() onTap,
    bool isDanger = false,
  }) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final activeBackground = isDanger
        ? colors.errorBackground
        : colors.primaryMain.withValues(alpha: 0.14);
    final activeForeground = isDanger ? colors.errorIcon : colors.primaryMain;

    return InkWell(
      onTap: () async {
        await onTap();
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.l,
          vertical: AppSizes.m,
        ),
        decoration: BoxDecoration(
          color: isActive ? activeBackground : colors.neutralBackground,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? activeForeground : colors.neutralBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSizes.iconS,
              color: isActive ? activeForeground : colors.neutralTextPrimary,
            ),
            const SizedBox(width: AppSizes.s),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isActive ? activeForeground : colors.neutralTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineErrorView(AppColorExtension colors) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.l),
      decoration: BoxDecoration(
        color: colors.errorBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.errorOccurred,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colors.errorIcon),
          ),
          const SizedBox(height: AppSizes.s),
          Text(
            _errorMessage ?? '',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSizes.m),
          ElevatedButton(
            onPressed: () => _loadTransactions(page: _currentPage),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineEmptyView(AppColorExtension colors) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.l),
      decoration: BoxDecoration(
        color: colors.neutralSurface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      ),
      child: Column(
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.neutralTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(AppSizes.l),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildPaginationSection(AppColorExtension colors) {
    final visibleItems = _transactions.length;
    final pageStart = _totalItems == 0
        ? 0
        : ((_currentPage - 1) * _pageSize) + 1;
    final pageEnd = _totalItems == 0 ? 0 : pageStart + visibleItems - 1;
    final progress = _totalPages <= 1 ? 1.0 : _currentPage / _totalPages;

    return Container(
      margin: const EdgeInsets.only(top: AppSizes.m),
      padding: const EdgeInsets.all(AppSizes.l),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.neutralSurface, colors.secondaryMain],
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        border: Border.all(color: colors.neutralBorder.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: colors.neutralBorder.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _textByLocale(
                    vi: 'Hiển thị $pageStart-$pageEnd / $_totalItems giao dịch',
                    en: 'Showing $pageStart-$pageEnd / $_totalItems transactions',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.neutralTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.m,
                  vertical: AppSizes.s,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryMain.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.primaryMain,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.m),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: colors.neutralBorder.withValues(alpha: 0.45),
              valueColor: AlwaysStoppedAnimation<Color>(colors.primaryMain),
            ),
          ),
          const SizedBox(height: AppSizes.l),
          Row(
            children: [
              Expanded(
                child: _buildPagerButton(
                  icon: Icons.chevron_left_rounded,
                  label: _textByLocale(vi: 'Trang trước', en: 'Previous'),
                  onPressed: _canGoPrevious ? _goToPreviousPage : null,
                ),
              ),
              const SizedBox(width: AppSizes.s),
              Expanded(
                child: _buildPagerButton(
                  icon: Icons.chevron_right_rounded,
                  label: _textByLocale(vi: 'Trang sau', en: 'Next'),
                  onPressed: _canGoNext ? _goToNextPage : null,
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPagerButton({
    required IconData icon,
    required String label,
    required Future<void> Function()? onPressed,
    bool isPrimary = false,
  }) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final isDisabled = onPressed == null;
    final backgroundColor = isPrimary
        ? colors.primaryMain
        : colors.neutralBackground;
    final foregroundColor = isPrimary
        ? colors.primaryText
        : colors.neutralTextPrimary;

    return InkWell(
      onTap: isDisabled
          ? null
          : () async {
              await onPressed();
            },
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.m,
          vertical: AppSizes.m,
        ),
        decoration: BoxDecoration(
          color: isDisabled
              ? colors.neutralBorder.withValues(alpha: 0.35)
              : backgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
          border: Border.all(
            color: isPrimary ? colors.primaryMain : colors.neutralBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSizes.iconS,
              color: isDisabled ? colors.neutralTextDisable : foregroundColor,
            ),
            const SizedBox(width: AppSizes.s),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDisabled
                      ? colors.neutralTextDisable
                      : foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialLoadingView() {
    return const SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator()),
      ),
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
              Icon(
                Icons.lock_outline,
                size: 64,
                color: colors.neutralTextSecondary,
              ),
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
