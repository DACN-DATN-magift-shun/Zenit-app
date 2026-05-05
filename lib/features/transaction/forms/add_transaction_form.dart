import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/forms/form_fields/custom_text_form_field.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/services/navigation_service.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_flash.dart';
import 'package:zenit/core/widgets/app_drawer.dart';
import 'package:zenit/features/transaction/forms/add_transaction_form_helpers.dart';
import 'package:zenit/features/transaction/forms/add_transaction_form_prefill_helper.dart';
import 'package:zenit/features/transaction/forms/add_transaction_form_validators.dart';
import 'package:zenit/features/transaction/widgets/category_selector_drawer.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';
import 'package:zenit/features/setting_childs/money_source_manage/providers/money_source_provider.dart';

class TransactionFormData {
  final String title;
  final String note;
  final int amount;
  final DateTime transactionDate;
  final String categoryId;
  final String walletId;
  final XFile? photoFile;
  final bool collectLaterEnabled;
  final int? loanAmount;
  final DateTime? loanDueDate;

  TransactionFormData({
    required this.title,
    required this.note,
    required this.amount,
    required this.transactionDate,
    required this.categoryId,
    required this.walletId,
    this.photoFile,
    this.collectLaterEnabled = false,
    this.loanAmount,
    this.loanDueDate,
  });
}

class AddTransactionForm extends StatefulWidget {
  final Function(TransactionFormData? Function() getFormData)? onFormReady;
  final Future<AddTransactionFormPrefillResult> Function(
    MoneySourceProvider moneySourceProvider,
    CategoryProvider categoryProvider,
  )? prefillLoader;

  const AddTransactionForm({
    super.key,
    this.onFormReady,
    this.prefillLoader,
  });

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _loanAmountController = TextEditingController();
  final _noteController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  DateTime _selectedDate = DateTime.now();
  DateTime _loanDueDate = DateTime.now();
  CategoryModel? _selectedCategory;
  MoneySourceModel? _selectedWallet;
  XFile? _selectedPhoto;
  bool _isIncomeTransaction = false;
  bool _collectLaterEnabled = false;
  bool _isUpdatingAmountField = false;
  late AnimationController _walletSwitchController;
  int _currentWalletIndex = -1;

  @override
  void initState() {
    super.initState();
    _walletSwitchController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillFormFromRecentTransaction();
    });
  }

  Future<void> _prefillFormFromRecentTransaction() async {
    final moneySourceProvider = context.read<MoneySourceProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    final prefill = widget.prefillLoader != null
        ? await widget.prefillLoader!(moneySourceProvider, categoryProvider)
        : await AddTransactionFormPrefillHelper.loadFromRecentTransaction(
            moneySourceProvider: moneySourceProvider,
            categoryProvider: categoryProvider,
          );

    if (!mounted || moneySourceProvider.moneySources.isEmpty) return;

    final selectedWallet =
        prefill.wallet ?? moneySourceProvider.moneySources.first;
    final index = moneySourceProvider.moneySources.indexWhere(
      (w) => w.id == selectedWallet.id,
    );

    setState(() {
      _selectedWallet = selectedWallet;
      if (prefill.category != null) {
        _selectedCategory = prefill.category;
      }
      if (prefill.isIncomeTransaction != null) {
        _isIncomeTransaction = prefill.isIncomeTransaction!;
      }
      _currentWalletIndex = index >= 0 ? index : 0;
    });

    widget.onFormReady?.call(_getFormData);
  }

  @override
  void dispose() {
    _walletSwitchController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _loanAmountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        if (_collectLaterEnabled && _loanDueDate.isBefore(_selectedDate)) {
          _loanDueDate = _selectedDate;
        }
      });
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (picked == null || !mounted) return;
      setState(() => _selectedPhoto = picked);
    } catch (e) {
      if (!mounted) return;
      AppFlash.error(
        context,
        context.l10n.genericErrorWithReason(e.toString()),
      );
    }
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
              ? 'Quản lý danh mục'
              : 'Manage categories',
        ),
      ],
      body: CategorySelectorDrawer(
        selectedCategory: _selectedCategory,
        allowedGroupTypes: allowedGroupTypes,
        onCategorySelected: (category) {
          setState(() => _selectedCategory = category);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showWalletSelector() {
    AddTransactionFormHelpers.showWalletSelector(
      context: context,
      selectedWallet: _selectedWallet,
      onWalletSelected: (wallet) {
        setState(() => _selectedWallet = wallet);
        Navigator.of(context).pop();
      },
    );
  }

  int _selectedAmountValue() =>
      AddTransactionFormHelpers.selectedAmountValue(_amountController);
  int? _getLoanAmountValue() =>
      AddTransactionFormHelpers.loanAmountValue(_loanAmountController);

  int? _getNetTransactionAmount() {
    return AddTransactionFormHelpers.netTransactionAmount(
      transactionAmount: _selectedAmountValue(),
      collectLaterEnabled: _collectLaterEnabled,
      loanAmount: _getLoanAmountValue(),
    );
  }

  void _toggleCollectLater(bool enabled) {
    setState(() {
      _collectLaterEnabled = enabled;
      if (_collectLaterEnabled) {
        _isIncomeTransaction = false;
        if (_selectedCategory != null &&
            !_isCategoryCompatibleWithCurrentType(_selectedCategory!)) {
          _selectedCategory = null;
        }
      }
      if (_collectLaterEnabled && _loanDueDate.isBefore(_selectedDate)) {
        _loanDueDate = _selectedDate;
      }
    });
  }

  TransactionFormData? _getFormData() {
    if (!_formKey.currentState!.validate()) return null;
    if (_selectedCategory == null) {
      AppFlash.warning(context, context.l10n.selectCategoryWarning);
      return null;
    }
    if (_selectedWallet == null) {
      AppFlash.warning(context, _selectWalletWarning(context));
      return null;
    }

    final collectLaterError =
        AddTransactionFormValidators.validateCollectLaterRule(
          collectLaterEnabled: _collectLaterEnabled,
          transactionAmount: _selectedAmountValue(),
          loanAmount: _getLoanAmountValue(),
          loanDueDate: _loanDueDate,
          transactionDate: _selectedDate,
          isVietnamese: _isVietnamese(context),
        );
    if (collectLaterError != null) {
      AppFlash.warning(context, collectLaterError);
      return null;
    }

    return TransactionFormData(
      title: _titleController.text.trim(),
      note: _noteController.text.trim(),
      amount: int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0,
      transactionDate: _selectedDate,
      categoryId: _selectedCategory!.id,
      walletId: _selectedWallet!.id,
      photoFile: _selectedPhoto,
      collectLaterEnabled: _collectLaterEnabled,
      loanAmount: _collectLaterEnabled ? _getLoanAmountValue() : null,
      loanDueDate: _collectLaterEnabled ? _loanDueDate : null,
    );
  }

  bool _isVietnamese(BuildContext context) =>
      AddTransactionFormHelpers.isVietnamese(context);
  String _walletFieldLabel(BuildContext context) =>
      AddTransactionFormHelpers.walletFieldLabel(context);
  String _photoFieldLabel(BuildContext context) =>
      AddTransactionFormHelpers.photoFieldLabel(context);
  String _typeFieldLabel(BuildContext context) =>
      AddTransactionFormHelpers.typeFieldLabel(context);
  String _incomeLabel(BuildContext context) =>
      AddTransactionFormHelpers.incomeLabel(context);
  String _expenseLabel(BuildContext context) =>
      AddTransactionFormHelpers.expenseLabel(context);
  bool _isCategoryCompatibleWithCurrentType(CategoryModel category) =>
      AddTransactionFormHelpers.isCategoryCompatibleWithCurrentType(
        category,
        _isIncomeTransaction,
      );
  String _selectWalletWarning(BuildContext context) =>
      AddTransactionFormHelpers.selectWalletWarning(context);
  String? _validateTitle(String? value) =>
      AddTransactionFormValidators.validateTitle(context, value);
  String? _validateAmount(String? value) =>
      AddTransactionFormValidators.validateAmount(context, value);

  void _setAmountText(String text) {
    _isUpdatingAmountField = true;
    _amountController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _isUpdatingAmountField = false;
    if (mounted) setState(() {});
  }

  String _formatNumberWithCommas(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final indexFromRight = raw.length - i;
      buffer.write(raw[i]);
      if (indexFromRight > 1 && indexFromRight % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  bool _isOperator(String char) =>
      char == '+' || char == '-' || char == '*' || char == '/';

  int _precedence(String op) {
    if (op == '+' || op == '-') return 1;
    if (op == '*' || op == '/') return 2;
    return 0;
  }

  int? _applyOperator(int left, int right, String op) {
    switch (op) {
      case '+':
        return left + right;
      case '-':
        return left - right;
      case '*':
        return left * right;
      case '/':
        if (right == 0) return null;
        return left ~/ right;
      default:
        return null;
    }
  }

  int? _evaluateExpression(String expression) {
    final normalized = expression.replaceAll(',', '').replaceAll(' ', '');
    if (normalized.isEmpty) return null;

    if (normalized.startsWith('-') || _isOperator(normalized[0])) {
      return null;
    }
    if (_isOperator(normalized[normalized.length - 1])) {
      return null;
    }

    final values = <int>[];
    final operators = <String>[];
    int i = 0;

    while (i < normalized.length) {
      final char = normalized[i];

      if (_isOperator(char)) {
        while (operators.isNotEmpty &&
            _precedence(operators.last) >= _precedence(char)) {
          if (values.length < 2) return null;
          final right = values.removeLast();
          final left = values.removeLast();
          final result = _applyOperator(left, right, operators.removeLast());
          if (result == null) return null;
          values.add(result);
        }
        operators.add(char);
        i++;
        continue;
      }

      if (RegExp(r'\d').hasMatch(char)) {
        int j = i;
        while (j < normalized.length && RegExp(r'\d').hasMatch(normalized[j])) {
          j++;
        }
        final value = int.tryParse(normalized.substring(i, j));
        if (value == null) return null;
        values.add(value);
        i = j;
        continue;
      }

      return null;
    }

    while (operators.isNotEmpty) {
      if (values.length < 2) return null;
      final right = values.removeLast();
      final left = values.removeLast();
      final result = _applyOperator(left, right, operators.removeLast());
      if (result == null) return null;
      values.add(result);
    }

    return values.length == 1 ? values.first : null;
  }

  void _cycleWallet(bool isNextWallet) {
    final moneySourceProvider = context.read<MoneySourceProvider>();
    if (moneySourceProvider.moneySources.isEmpty) return;

    final nextIndex = isNextWallet
        ? (_currentWalletIndex + 1) % moneySourceProvider.moneySources.length
        : (_currentWalletIndex - 1 + moneySourceProvider.moneySources.length) %
              moneySourceProvider.moneySources.length;

    setState(() {
      _currentWalletIndex = nextIndex;
      _selectedWallet = moneySourceProvider.moneySources[nextIndex];
    });

    _walletSwitchController.forward(from: 0.0);
  }

  void _handleAmountChanged(String value) {
    if (_isUpdatingAmountField) return;

    final normalized = value.replaceAll(' ', '');

    if (normalized.contains('=')) {
      final expression = normalized.replaceAll('=', '');
      final result = _evaluateExpression(expression);
      if (result != null) {
        _setAmountText(_formatNumberWithCommas(result));
      } else if (mounted) {
        AppFlash.warning(
          context,
          _isVietnamese(context)
              ? 'Biểu thức không hợp lệ hoặc chia cho 0'
              : 'Invalid expression or division by zero',
        );
      }
      return;
    }

    if (RegExp(r'[+\-*/]').hasMatch(normalized)) {
      if (mounted) setState(() {});
      return;
    }

    if (normalized.isEmpty) {
      if (mounted) setState(() {});
      return;
    }

    final parsed = int.tryParse(normalized.replaceAll(',', ''));
    if (parsed == null) {
      if (mounted) setState(() {});
      return;
    }

    _setAmountText(_formatNumberWithCommas(parsed));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.l)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Amount (moved to top, larger) ---
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.78,
                      child: TextFormField(
                        key: const ValueKey('transaction-amount-field'),
                        controller: _amountController,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9+\-*/,= ]'),
                          ),
                        ],
                        textAlign: TextAlign.center,
                        onChanged: _handleAmountChanged,
                        decoration: InputDecoration(
                          filled: false,
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: colors.neutralTextDisable,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                        validator: _validateAmount,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      'VND',
                      style: TextStyle(
                        color: colors.neutralTextSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.l),

              // --- Title with leading icon ---
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: colors.primaryMain,
                      size: 26,
                    ),
                    const SizedBox(width: AppSizes.s),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.55,
                      child: TextFormField(
                        key: const ValueKey('transaction-title-field'),
                        controller: _titleController,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          filled: false,
                          hintText: l10n.transactionName,
                          hintStyle: TextStyle(
                            color: colors.neutralTextDisable.withOpacity(0.5),
                            fontWeight: FontWeight.w700,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        validator: _validateTitle,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.l),
              Container(
                decoration: BoxDecoration(
                  color: colors.primaryMain.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(
                    AppSizes.borderRadiusMedium,
                  ),
                  border: Border.all(
                    color: colors.primaryMain.withOpacity(0.12),
                  ),
                ),
                child: ExpansionTile(
                  key: ValueKey(_collectLaterEnabled),
                  initiallyExpanded: _collectLaterEnabled,
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.m,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(
                    AppSizes.m,
                    0,
                    AppSizes.m,
                    AppSizes.m,
                  ),
                  shape: const RoundedRectangleBorder(side: BorderSide.none),
                  collapsedShape: const RoundedRectangleBorder(
                    side: BorderSide.none,
                  ),
                  leading: Checkbox(
                    value: _collectLaterEnabled,
                    onChanged: (value) => _toggleCollectLater(value ?? false),
                    visualDensity: VisualDensity.compact,
                  ),
                  title: Text(
                    _isVietnamese(context)
                        ? 'Chi hộ - thu hồi sau'
                        : 'Pay on behalf - collect later',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.neutralTextPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  children: _collectLaterEnabled
                      ? [
                          const SizedBox(height: AppSizes.s),
                          CustomTextFormField(
                            key: const ValueKey('transaction-loan-amount-field'),
                            label: _isVietnamese(context)
                                ? 'Số tiền khoản vay'
                                : 'Loan amount',
                            hintText: _isVietnamese(context)
                                ? 'Nhập số tiền khoản vay'
                                : 'Enter loan amount',
                            controller: _loanAmountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textAlign: TextAlign.end,
                            validator: (value) =>
                                AddTransactionFormValidators.validateLoanAmountField(
                                  context,
                                  collectLaterEnabled: _collectLaterEnabled,
                                  value: value,
                                  transactionAmount: _selectedAmountValue(),
                                  isVietnamese: _isVietnamese(context),
                                ),
                          ),
                          const SizedBox(height: AppSizes.m),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _loanDueDate,
                                firstDate: _selectedDate,
                                lastDate: DateTime(2030),
                                builder: (context, child) {
                                  final colors = Theme.of(
                                    context,
                                  ).extension<AppColorExtension>()!;
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
                              if (picked != null && mounted) {
                                setState(() => _loanDueDate = picked);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.xs,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _isVietnamese(context)
                                        ? 'Ngày đến hạn'
                                        : 'Due date',
                                    style: TextStyle(
                                      color: colors.neutralTextPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    AddTransactionFormHelpers.formatDate(
                                      _loanDueDate,
                                    ),
                                    style: TextStyle(
                                      color: colors.neutralTextSecondary,
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
                          const SizedBox(height: AppSizes.s),
                          _buildLoanSummary(context),
                        ]
                      : [],
                ),
              ),

              // --- Các dòng khác ---
              _buildFieldRow(
                context,
                label: l10n.time,
                leadingIcon: Icons.schedule_rounded,
                child: InkWell(
                  onTap: _selectDate,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _selectedDate.day == DateTime.now().day &&
                                _selectedDate.month == DateTime.now().month &&
                                _selectedDate.year == DateTime.now().year
                            ? l10n.today
                            : AddTransactionFormHelpers.formatDate(
                                _selectedDate,
                              ),
                        style: TextStyle(color: colors.neutralTextDisable),
                      ),
                      const SizedBox(width: AppSizes.s),
                      Icon(
                        Symbols.calendar_month_rounded,
                        color: colors.primaryMain,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              _buildFieldRow(
                context,
                label: _typeFieldLabel(context),
                leadingIcon: Icons.compare_arrows_rounded,
                child: SegmentedButton<int>(
                  key: const ValueKey('transaction-type-selector'),
                  segments: [
                    ButtonSegment<int>(
                      value: 0,
                      label: KeyedSubtree(
                        key: const ValueKey('transaction-type-expense'),
                        child: Text(_expenseLabel(context)),
                      ),
                    ),
                    ButtonSegment<int>(
                      value: 1,
                      label: KeyedSubtree(
                        key: const ValueKey('transaction-type-income'),
                        child: Text(_incomeLabel(context)),
                      ),
                    ),
                  ],
                  selected: {_isIncomeTransaction ? 1 : 0},
                  style: ButtonStyle(
                    side: const WidgetStatePropertyAll(BorderSide.none),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.selected)
                          ? const Color(0xFFD2E4FF)
                          : Theme.of(context).colorScheme.surfaceContainerHigh;
                    }),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  onSelectionChanged: (selection) {
                    final nextIsIncome = selection.first == 1;
                    setState(() {
                      if (_collectLaterEnabled && nextIsIncome)
                        _collectLaterEnabled = false;
                      _isIncomeTransaction = nextIsIncome;
                      if (_selectedCategory != null &&
                          !_isCategoryCompatibleWithCurrentType(
                            _selectedCategory!,
                          )) {
                        _selectedCategory = null;
                      }
                    });
                  },
                ),
              ),

              _buildFieldRow(
                context,
                label: l10n.singleCategory,
                leadingIcon: Icons.sell_rounded,
                child: InkWell(
                  key: const ValueKey('transaction-category-selector'),
                  onTap: _showCategorySelector,
                  child: _selectedCategory != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.m,
                            vertical: AppSizes.s,
                          ),
                          decoration: BoxDecoration(
                            color: AddTransactionFormHelpers.parseColor(
                              _selectedCategory!.backgroundColor,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadiusXSmall,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedCategory!.name,
                                style: TextStyle(
                                  color: AddTransactionFormHelpers.parseColor(
                                    _selectedCategory!.color,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Symbols.sell_rounded,
                                size: 16,
                                color: AddTransactionFormHelpers.parseColor(
                                  _selectedCategory!.color,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Row(
                          children: [
                            Text(
                              l10n.select,
                              style: TextStyle(
                                color: colors.neutralTextDisable,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: colors.primaryMain,
                            ),
                          ],
                        ),
                ),
              ),

              _buildFieldRow(
                context,
                label: _walletFieldLabel(context),
                leadingIcon: Icons.account_balance_wallet_rounded,
                child: _selectedWallet != null
                    ? GestureDetector(
                        key: const ValueKey('transaction-wallet-selector'),
                        onHorizontalDragEnd: (details) {
                          const swipeThreshold = 50.0;
                          if (details.primaryVelocity == null) return;
                          if (details.primaryVelocity! > swipeThreshold) {
                            _cycleWallet(false);
                          } else if (details.primaryVelocity! <
                              -swipeThreshold) {
                            _cycleWallet(true);
                          }
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) {
                            final slide =
                                Tween<Offset>(
                                  begin: const Offset(0.12, 0),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                    reverseCurve: Curves.easeInCubic,
                                  ),
                                );
                            final scale = Tween<double>(begin: 0.96, end: 1.0)
                                .animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                    reverseCurve: Curves.easeIn,
                                  ),
                                );
                            final fade = Tween<double>(begin: 0.0, end: 1.0)
                                .animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                    reverseCurve: Curves.easeIn,
                                  ),
                                );
                            final rotate = Tween<double>(begin: 0.08, end: 0.0)
                                .animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                    reverseCurve: Curves.easeInCubic,
                                  ),
                                );

                            return FadeTransition(
                              opacity: fade,
                              child: SlideTransition(
                                position: slide,
                                child: ScaleTransition(
                                  scale: scale,
                                  child: RotationTransition(
                                    turns: rotate,
                                    child: child,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: InkWell(
                            key: ValueKey(_selectedWallet!.id),
                            onTap: _showWalletSelector,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.m,
                                vertical: AppSizes.s,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedWallet!.backgroundColor
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.borderRadiusXSmall,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _selectedWallet!.iconData,
                                    size: 16,
                                    color: _selectedWallet!.iconColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _selectedWallet!.name,
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
                      )
                      : InkWell(
                        key: const ValueKey('transaction-wallet-selector'),
                        onTap: _showWalletSelector,
                        child: Row(
                          children: [
                            Text(
                              l10n.select,
                              style: TextStyle(
                                color: colors.neutralTextDisable,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: colors.primaryMain,
                            ),
                          ],
                        ),
                      ),
              ),

              _buildFieldRow(
                context,
                label: _photoFieldLabel(context),
                leadingIcon: Icons.photo_library_rounded,
                child: InkWell(
                  onTap: _pickPhoto,
                  child: Row(
                    children: [
                      Icon(
                        _selectedPhoto != null
                            ? Symbols.image_rounded
                            : Symbols.add_photo_alternate_rounded,
                        color: colors.primaryMain,
                        size: 18,
                      ),
                      const SizedBox(width: AppSizes.xs),
                      Text(
                        _selectedPhoto != null
                            ? _selectedPhoto!.name
                            : (_isVietnamese(context)
                                  ? 'Chọn ảnh'
                                  : 'Choose photo'),
                        style: TextStyle(color: colors.neutralTextSecondary),
                      ),
                      if (_selectedPhoto != null) ...[
                        const SizedBox(width: AppSizes.xs),
                        GestureDetector(
                          onTap: () => setState(() => _selectedPhoto = null),
                          child: Icon(
                            Symbols.close_rounded,
                            size: 16,
                            color: colors.primaryMain,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.l),

              // --- Note Field ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.sticky_note_2_rounded,
                        size: 18,
                        color: colors.primaryMain,
                      ),
                      const SizedBox(width: AppSizes.s),
                      Text(
                        l10n.note,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: colors.neutralTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.s),
                  TextFormField(
                    controller: _noteController,
                    minLines: 3,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colors.neutralSurface.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.borderRadiusMedium,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(AppSizes.m),
                      hintText: _isVietnamese(context)
                          ? 'Thêm ghi chú...'
                          : 'Add note...',
                      hintStyle: TextStyle(color: colors.neutralTextDisable),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldRow(
    BuildContext context, {
    required String label,
    required IconData leadingIcon,
    required Widget child,
  }) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.l),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(leadingIcon, size: 18, color: colors.primaryMain),
              const SizedBox(width: AppSizes.s),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: colors.neutralTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSizes.l),
          child,
        ],
      ),
    );
  }

  Widget _buildLoanSummary(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final summaryText = AddTransactionFormHelpers.loanSummaryText(
      context,
      transactionAmount: _selectedAmountValue(),
      loanAmount: _getLoanAmountValue(),
      remainingAmount: _getNetTransactionAmount(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
      child: Text(
        summaryText,
        style: TextStyle(
          color: colors.neutralTextSecondary,
          fontWeight: FontWeight.w400,
          fontSize: AppSizes.textS,
          height: 1.35,
        ),
      ),
    );
  }
}
