import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/services/navigation_service.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/authenticated_network_image.dart';
import 'package:zenit/core/widgets/app_flash.dart';
import 'package:zenit/core/widgets/app_drawer.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';
import 'package:zenit/features/setting_childs/money_source_manage/providers/money_source_provider.dart';
import 'package:zenit/features/setting_childs/money_source_manage/widgets/money_source_selector_drawer.dart';
import 'package:zenit/features/transaction/models/transaction_model.dart';
import 'package:zenit/features/transaction/services/transaction_service.dart';
import 'package:zenit/features/transaction/widgets/category_selector_drawer.dart';
import 'package:zenit/features/photos/services/photo_service.dart';

class ViewEditTranFormController {
  _ViewEditTranFormState? _state;
  final ValueNotifier<bool> isEditing = ValueNotifier(false);
  final ValueNotifier<bool> isSaving = ValueNotifier(false);

  Future<void> startEditing() async {
    await _state?._startEditing();
  }

  Future<void> saveChanges() async {
    await _state?._saveChanges();
  }

  void cancelEditing() {
    _state?._cancelEditing();
  }

  void _attach(_ViewEditTranFormState state) {
    _state = state;
  }

  void _detach(_ViewEditTranFormState state) {
    if (_state == state) {
      _state = null;
    }
  }

  void dispose() {
    isEditing.dispose();
    isSaving.dispose();
  }
}

class ViewEditTranForm extends StatefulWidget {
  final String transactionId;
  final TransactionModel? initialTransaction;
  final ViewEditTranFormController? controller;
  final Future<void> Function()? onTransactionUpdated;

  const ViewEditTranForm({
    super.key,
    required this.transactionId,
    this.initialTransaction,
    this.controller,
    this.onTransactionUpdated,
  });

  @override
  State<ViewEditTranForm> createState() => _ViewEditTranFormState();
}

class _ViewEditTranFormState extends State<ViewEditTranForm> {
  final _formKey = GlobalKey<FormState>();
  final TransactionService _transactionService = TransactionService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final PhotoService _photoService = PhotoService();

  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  String? _errorMessage;
  TransactionModel? _transaction;
  DateTime? _selectedDateTime;
  CategoryModel? _selectedCategory;
  MoneySourceModel? _selectedWallet;
  XFile? _selectedPhoto;
  bool _isIncomeTransaction = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    widget.controller?.isEditing.value = _isEditing;
    widget.controller?.isSaving.value = _isSaving;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = context.read<CategoryProvider>();
      if (!categoryProvider.hasData) {
        categoryProvider.loadAllCategories();
      }
      final moneySourceProvider = context.read<MoneySourceProvider>();
      if (!moneySourceProvider.hasData) {
        moneySourceProvider.loadAllMoneySources();
      }
    });
    _initializeTransaction();
  }

  @override
  void didUpdateWidget(covariant ViewEditTranForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
      widget.controller?.isEditing.value = _isEditing;
      widget.controller?.isSaving.value = _isSaving;
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _initializeTransaction() async {
    final initialTransaction = widget.initialTransaction;
    if (initialTransaction != null) {
      _populateForm(initialTransaction);
      if (!mounted) {
        return;
      }

      setState(() {
        _transaction = initialTransaction;
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transaction = await _transactionService.getTransactionById(
        widget.transactionId,
      );
      _populateForm(transaction);
      setState(() {
        _transaction = transaction;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _populateForm(TransactionModel transaction) {
    _titleController.text = transaction.title;
    _amountController.text = transaction.amount.toString();
    _noteController.text = transaction.note ?? '';
    _selectedDateTime = transaction.transactionDate.toLocal();
    _selectedCategory =
        _findCategoryById(transaction.categoryId) ??
        _mapCategoryFromTransaction(transaction);
    _selectedWallet = _findWalletById(transaction.walletId);

    // Determine if this is an income transaction based on category
    final category = _selectedCategory;
    if (category != null) {
      final groupType = int.tryParse(category.groupType) ?? 0;
      _isIncomeTransaction = groupType == GroupType.income.value;
    }
  }

  void _setEditing(bool value) {
    if (!mounted) {
      widget.controller?.isEditing.value = value;
      return;
    }

    setState(() {
      _isEditing = value;
    });
    widget.controller?.isEditing.value = value;
  }

  void _setSaving(bool value) {
    if (mounted) {
      setState(() {
        _isSaving = value;
      });
    }
    widget.controller?.isSaving.value = value;
  }

  Future<void> _startEditing() async {
    if (_isLoading || _transaction == null || _isSaving) {
      return;
    }

    FocusScope.of(context).unfocus();
    if (!_isEditing) {
      _setEditing(true);
    }
  }

  Future<void> _saveChanges() async {
    if (_isLoading || _transaction == null || _isSaving || !_isEditing) {
      return;
    }

    FocusScope.of(context).unfocus();
    await _submitUpdate();
  }

  void _cancelEditing() {
    if (_isLoading || _transaction == null || _isSaving || !_isEditing) {
      return;
    }

    FocusScope.of(context).unfocus();
    _populateForm(_transaction!);
    _formKey.currentState?.reset();
    _setEditing(false);
  }

  Future<void> _submitUpdate() async {
    final transaction = _transaction;
    if (transaction == null) {
      return;
    }

    final fallbackId = widget.transactionId.trim();
    final transactionId = (transaction.id != null && transaction.id!.isNotEmpty)
        ? transaction.id!
        : fallbackId;

    if (transactionId.isEmpty) {
      if (mounted) {
        AppFlash.error(context, context.l10n.transactionIdMissingUpdate);
      }
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final category =
        _selectedCategory ?? _findCategoryById(transaction.categoryId);
    if (category == null) {
      AppFlash.warning(context, context.l10n.selectCategoryWarning);
      return;
    }

    final wallet = _selectedWallet ?? _findWalletById(transaction.walletId);
    if (wallet == null) {
      AppFlash.warning(
        context,
        _isVietnamese(context)
            ? 'Vui lòng chọn ví cho giao dịch'
            : 'Please select a wallet for this transaction',
      );
      return;
    }

    final amount = _parseAmount(_amountController.text);
    if (amount == null || amount == 0) {
      AppFlash.warning(context, context.l10n.enterValidAmount);
      return;
    }

    final updatedTransaction = transaction.copyWith(
      id: transactionId,
      title: _titleController.text.trim(),
      note: _noteController.text.trim(),
      amount: amount,
      transactionDate: (_selectedDateTime ?? transaction.transactionDate)
          .toLocal(),
      categoryId: category.id,
      category: _mapTransactionCategory(category),
      walletId: wallet.id,
    );

    _setSaving(true);
    try {
      if (_selectedPhoto != null) {
        await _photoService.uploadPhoto(
          file: _selectedPhoto!,
          transactionId: transactionId,
        );
      }

      await _transactionService.updateTransactions([updatedTransaction]);

      if (!mounted) {
        return;
      }

      setState(() {
        _transaction = updatedTransaction;
        _selectedPhoto = null;
      });
      _setEditing(false);

      AppFlash.success(context, context.l10n.updateTransactionSuccess);

      await widget.onTransactionUpdated?.call();
    } catch (e) {
      if (!mounted) {
        return;
      }

      AppFlash.error(
        context,
        context.l10n.genericErrorWithReason(e.toString()),
      );
    } finally {
      _setSaving(false);
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked == null || !mounted) {
        return;
      }

      setState(() {
        _selectedPhoto = picked;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      AppFlash.error(
        context,
        context.l10n.genericErrorWithReason(e.toString()),
      );
    }
  }

  Future<void> _selectTransactionDateTime() async {
    final initialDateTime =
        _selectedDateTime ??
        _transaction?.transactionDate.toLocal() ??
        DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        final colors = Theme.of(context).extension<AppColorExtension>()!;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colors.primaryMain,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: colors.neutralTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
      builder: (context, child) {
        final colors = Theme.of(context).extension<AppColorExtension>()!;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colors.primaryMain,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: colors.neutralTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _showCategorySelector() {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final allowedGroupTypes = _isIncomeTransaction
        ? <int>{GroupType.income.value}
        : <int>{
            GroupType.necessary.value,
            GroupType.assets.value,
            GroupType.selfDevelopment.value,
            GroupType.entertainment.value,
            GroupType.giving.value,
          };

    AppDrawer.showAsBottomSheet(
      context: context,
      title: context.l10n.chooseTagForTransaction,
      showCloseButton: false,
      showDragHandle: true,
      height: MediaQuery.of(context).size.height * 0.85,
      headerActions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
            NavigationService.instance
                .navigateTo('/settings/category_manage')
                ?.then((_) {
                  if (!mounted) return;
                  context.read<CategoryProvider>().refreshCategories();
                });
          },
          icon: Icon(Symbols.settings_rounded, color: colors.primaryMain),
          tooltip: _isVietnamese(context)
              ? 'Quan ly danh muc'
              : 'Manage categories',
        ),
      ],
      body: CategorySelectorDrawer(
        selectedCategory: _selectedCategory,
        allowedGroupTypes: allowedGroupTypes,
        onCategorySelected: (category) {
          setState(() {
            _selectedCategory = category;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year - $hour:$minute';
  }

  String _formatCurrency(int amount) {
    final isNegative = amount < 0;
    final amountStr = amount.abs().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = amountStr.length - 1; i >= 0; i--) {
      buffer.write(amountStr[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    final formatted = buffer.toString().split('').reversed.join();
    return '${isNegative ? '-' : ''}$formatted VND';
  }

  int? _parseAmount(String value) {
    final normalized = value.replaceAll(RegExp(r'[\s,.]'), '');
    if (normalized.isEmpty) {
      return null;
    }
    return int.tryParse(normalized);
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.enterAmount;
    }

    final amount = _parseAmount(value);
    if (amount == null || amount == 0) {
      return context.l10n.enterValidAmount;
    }

    return null;
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.transactionName;
    }
    return null;
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Colors.grey;
    try {
      String hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
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

  CategoryModel? _findCategoryById(String categoryId) {
    final categories = context.read<CategoryProvider>().categories;
    for (final category in categories) {
      if (category.id == categoryId) {
        return category;
      }
    }
    return null;
  }

  CategoryModel? _mapCategoryFromTransaction(TransactionModel transaction) {
    final category = transaction.category;
    if (category == null) {
      return null;
    }

    return CategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      color: category.color,
      backgroundColor: category.backgroundColor,
      groupType: category.groupType.toString(),
    );
  }

  TransactionCategoryModel _mapTransactionCategory(CategoryModel category) {
    return TransactionCategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      color: category.color,
      backgroundColor: category.backgroundColor,
      groupType: int.tryParse(category.groupType) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.l)),
      ),
      child: Form(key: _formKey, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final l10n = context.l10n;

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.xl),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: colors.errorIcon, size: 48),
              const SizedBox(height: AppSizes.m),
              Text(
                l10n.transactionLoadError,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSizes.s),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.neutralTextSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.m),
              ElevatedButton(
                onPressed: _initializeTransaction,
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_transaction == null) {
      return Padding(
        padding: EdgeInsets.all(AppSizes.xl),
        child: Center(child: Text(l10n.transactionNotFound)),
      );
    }

    final t = _transaction!;
    final categoryProvider = context.watch<CategoryProvider>();
    final matchedCategory = categoryProvider.categories.where(
      (c) => c.id == t.categoryId,
    );
    final providerCategory = matchedCategory.isNotEmpty
        ? matchedCategory.first
        : null;
    final category =
        _selectedCategory ?? providerCategory ?? _mapCategoryFromTransaction(t);
    final categoryName = category?.name ?? t.category?.name ?? l10n.unknown;
    final categoryColor = category?.color ?? t.category?.color ?? '#9E9E9E';
    final categoryBgColor =
        category?.backgroundColor ?? t.category?.backgroundColor ?? '#F5F5F5';
    final categoryIcon = category?.icon ?? t.category?.icon ?? 'category';

    final moneySourceProvider = context.watch<MoneySourceProvider>();
    final matchedWallet = moneySourceProvider.moneySources.where(
      (w) => w.id == t.walletId,
    );
    final providerWallet = matchedWallet.isNotEmpty
        ? matchedWallet.first
        : null;
    final wallet = _selectedWallet ?? providerWallet;
    final walletName = wallet?.name ?? l10n.unknown;
    final walletIcon = wallet?.iconName ?? 'account_balance_wallet_rounded';
    final walletColor = wallet?.iconColor ?? const Color(0xFF111111);
    final walletBgColor = wallet?.backgroundColor ?? const Color(0xFFF5F5F5);

    final displayDate = (_selectedDateTime ?? t.transactionDate).toLocal();
    final noteText = (t.note != null && t.note!.isNotEmpty)
        ? t.note!
        : l10n.noteEmpty;
    final noteMaxHeight = _calculateNoteMaxHeight(context);

    return AbsorbPointer(
      absorbing: _isSaving,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: _isEditing
                  ? TextFormField(
                      controller: _titleController,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: colors.neutralTextSecondary,
                      ),
                      decoration: const InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      validator: _validateTitle,
                    )
                  : Text(
                      t.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: colors.neutralTextSecondary,
                      ),
                    ),
            ),
            const SizedBox(height: AppSizes.xl),

            _buildFieldRow(
              context,
              label: l10n.amount,
              child: _isEditing
                  ? SizedBox(
                      width: 180,
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                        ),
                        textAlign: TextAlign.end,
                        decoration: const InputDecoration(
                          filled: false,
                          fillColor: Colors.transparent,
                          hintText: '0',
                          suffixText: ' VND',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        validator: _validateAmount,
                      ),
                    )
                  : Text(
                      _formatCurrency(t.amount),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),

            _buildFieldRow(
              context,
              label: l10n.time,
              child: InkWell(
                onTap: _isEditing ? _selectTransactionDateTime : null,
                borderRadius: BorderRadius.circular(
                  AppSizes.borderRadiusXSmall,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDate(displayDate),
                      style: TextStyle(
                        color: colors.neutralTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: AppSizes.s),
                    Icon(
                      Symbols.calendar_month_rounded,
                      color: colors.neutralTextPrimary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            _buildFieldRow(
              context,
              label: _typeFieldLabel(context),
              child: _isEditing
                  ? SegmentedButton<int>(
                      segments: [
                        ButtonSegment<int>(
                          value: 0,
                          label: Text(_expenseLabel(context)),
                        ),
                        ButtonSegment<int>(
                          value: 1,
                          label: Text(_incomeLabel(context)),
                        ),
                      ],
                      selected: {_isIncomeTransaction ? 1 : 0},
                      style: ButtonStyle(
                        side: const MaterialStatePropertyAll(BorderSide.none),
                        backgroundColor: MaterialStateProperty.resolveWith((
                          states,
                        ) {
                          final isSelected = states.contains(
                            MaterialState.selected,
                          );
                          return isSelected
                              ? const Color(0xFFD2E4FF)
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh;
                        }),
                        foregroundColor: MaterialStateProperty.resolveWith((
                          states,
                        ) {
                          return Theme.of(context).colorScheme.onSurface;
                        }),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                      onSelectionChanged: (selection) {
                        final nextIsIncome = selection.first == 1;
                        setState(() {
                          _isIncomeTransaction = nextIsIncome;
                          if (_selectedCategory != null &&
                              !_isCategoryCompatibleWithCurrentType(
                                _selectedCategory!,
                              )) {
                            _selectedCategory = null;
                          }
                        });
                      },
                    )
                  : Text(
                      _isIncomeTransaction
                          ? _incomeLabel(context)
                          : _expenseLabel(context),
                      style: TextStyle(
                        color: colors.neutralTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),

            _buildFieldRow(
              context,
              label: l10n.category,
              child: InkWell(
                onTap: _isEditing ? _showCategorySelector : null,
                borderRadius: BorderRadius.circular(
                  AppSizes.borderRadiusXSmall,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.m,
                    vertical: AppSizes.s,
                  ),
                  decoration: BoxDecoration(
                    color: _parseColor(categoryBgColor).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      AppSizes.borderRadiusXSmall,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        categoryName,
                        style: TextStyle(
                          color: _parseColor(categoryColor),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _parseIcon(categoryIcon),
                        size: 16,
                        color: _parseColor(categoryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.l),

            _buildFieldRow(
              context,
              label: _isVietnamese(context) ? 'Ví' : 'Wallet',
              child: InkWell(
                onTap: _isEditing ? _showWalletSelector : null,
                borderRadius: BorderRadius.circular(
                  AppSizes.borderRadiusXSmall,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.m,
                    vertical: AppSizes.s,
                  ),
                  decoration: BoxDecoration(
                    color: walletBgColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      AppSizes.borderRadiusXSmall,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        MoneySourceIconMapper.fromName(walletIcon),
                        size: 16,
                        color: walletColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        walletName,
                        style: TextStyle(
                          color: colors.neutralTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            _buildFieldRow(
              context,
              label: _isVietnamese(context) ? 'Ảnh' : 'Photo',
              child: InkWell(
                onTap: _isEditing ? _pickPhoto : null,
                borderRadius: BorderRadius.circular(
                  AppSizes.borderRadiusXSmall,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _selectedPhoto != null
                          ? Symbols.image_rounded
                          : Symbols.add_photo_alternate_rounded,
                      color: colors.neutralTextSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      _selectedPhoto != null
                          ? _selectedPhoto!.name
                          : (_isVietnamese(context)
                                ? 'Chọn ảnh'
                                : 'Choose photo'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.neutralTextSecondary),
                    ),
                    if (_isEditing && _selectedPhoto != null) ...[
                      const SizedBox(width: AppSizes.xs),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPhoto = null;
                          });
                        },
                        child: Icon(
                          Symbols.close_rounded,
                          size: 16,
                          color: colors.neutralTextDisable,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (!_isEditing) ...[
              const SizedBox(height: AppSizes.s),
              _buildPhotoPreview(context, t.firstPhotoUrl),
            ],

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.note,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: colors.neutralTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.s),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: _isEditing ? 88 : 0,
                    maxHeight: noteMaxHeight,
                  ),
                  padding: _isEditing
                      ? EdgeInsets.zero
                      : const EdgeInsets.all(AppSizes.m),
                  decoration: BoxDecoration(
                    color: _isEditing
                        ? Colors.transparent
                        : colors.neutralBackground,
                    borderRadius: BorderRadius.circular(
                      AppSizes.borderRadiusMedium,
                    ),
                  ),
                  child: _isEditing
                      ? TextFormField(
                          controller: _noteController,
                          minLines: 1,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            filled: false,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(AppSizes.m),
                          ),
                        )
                      : SingleChildScrollView(
                          primary: false,
                          physics: const ClampingScrollPhysics(),
                          child: Text(
                            noteText,
                            style: TextStyle(
                              color: (t.note != null && t.note!.isNotEmpty)
                                  ? colors.neutralTextPrimary
                                  : colors.neutralTextDisable,
                              fontStyle: (t.note != null && t.note!.isNotEmpty)
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                            ),
                          ),
                        ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(BuildContext context, String? photoUrl) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    if (photoUrl == null || photoUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPhotoDialog(photoUrl),
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.neutralSurface,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
              border: Border.all(
                color: colors.neutralBorder.withValues(alpha: 0.6),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
              child: AuthenticatedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) {
                  return Icon(
                    Symbols.image_rounded,
                    color: colors.neutralTextDisable,
                    size: 26,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPhotoDialog(String photoUrl) async {
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(AppSizes.l),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: colors.neutralBackground,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.m,
                    AppSizes.s,
                    AppSizes.s,
                    AppSizes.s,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isVietnamese(context) ? 'Xem ảnh' : 'View photo',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Symbols.close_rounded),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.m,
                      0,
                      AppSizes.m,
                      AppSizes.m,
                    ),
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSizes.borderRadiusMedium,
                        ),
                        child: AuthenticatedNetworkImage(
                          imageUrl: photoUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stack) {
                            return SizedBox(
                              height: 220,
                              child: Center(
                                child: Text(
                                  _isVietnamese(context)
                                      ? 'Không tải được ảnh'
                                      : 'Unable to load photo',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _calculateNoteMaxHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final proposed = screenHeight * 0.30;

    if (proposed < 180) {
      return 180;
    }

    if (proposed > 280) {
      return 280;
    }

    return proposed;
  }

  Widget _buildFieldRow(
    BuildContext context, {
    required String label,
    required Widget child,
  }) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colors.neutralTextPrimary,
            ),
          ),
          const SizedBox(width: AppSizes.l),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: child),
          ),
        ],
      ),
    );
  }

  bool _isVietnamese(BuildContext context) {
    return Localizations.localeOf(context).languageCode.toLowerCase() == 'vi';
  }

  String _typeFieldLabel(BuildContext context) {
    return _isVietnamese(context) ? 'Phân loại' : 'Type';
  }

  String _incomeLabel(BuildContext context) {
    return _isVietnamese(context) ? 'Thu' : 'Income';
  }

  String _expenseLabel(BuildContext context) {
    return _isVietnamese(context) ? 'Chi' : 'Expense';
  }

  String _walletFieldLabel(BuildContext context) {
    return _isVietnamese(context) ? 'Ví' : 'Wallet';
  }

  bool _isCategoryCompatibleWithCurrentType(CategoryModel category) {
    final groupType = int.tryParse(category.groupType) ?? 0;
    final isIncomeCategory = groupType == GroupType.income.value;
    return _isIncomeTransaction ? isIncomeCategory : !isIncomeCategory;
  }

  MoneySourceModel? _findWalletById(String walletId) {
    final wallets = context.read<MoneySourceProvider>().moneySources;
    for (final wallet in wallets) {
      if (wallet.id == walletId) {
        return wallet;
      }
    }
    return null;
  }

  void _showWalletSelector() {
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    AppDrawer.showAsBottomSheet(
      context: context,
      title: _walletFieldLabel(context),
      showCloseButton: false,
      showDragHandle: true,
      height: MediaQuery.of(context).size.height * 0.75,
      headerActions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
            NavigationService.instance
                .navigateTo('/settings/money_source_manage')
                ?.then((_) {
                  if (!mounted) return;
                  context.read<MoneySourceProvider>().refreshMoneySources();
                });
          },
          icon: Icon(Symbols.settings_rounded, color: colors.primaryMain),
          tooltip: _isVietnamese(context)
              ? 'Quan ly nguon tien'
              : 'Manage wallets',
        ),
      ],
      body: MoneySourceSelectorDrawer(
        selectedWallet: _selectedWallet,
        onWalletSelected: (wallet) {
          setState(() {
            _selectedWallet = wallet;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
