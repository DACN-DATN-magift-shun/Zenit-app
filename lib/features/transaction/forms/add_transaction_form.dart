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
import 'package:zenit/features/transaction/forms/add_transaction_form_validators.dart';
import 'package:zenit/features/transaction/widgets/category_selector_drawer.dart';
import 'package:zenit/features/transaction/services/transaction_service.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';
import 'package:zenit/features/setting_childs/money_source_manage/providers/money_source_provider.dart';
import 'package:zenit/features/setting_childs/money_source_manage/widgets/money_source_selector_drawer.dart';

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

  const AddTransactionForm({super.key, this.onFormReady});

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final TransactionService _transactionService = TransactionService();
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = context.read<CategoryProvider>();
      if (!categoryProvider.hasData) {
        categoryProvider.loadAllCategories();
      }
      _autoSelectRecentlyUsedWallet();
      widget.onFormReady?.call(_getFormData);
    });
  }

  Future<void> _autoSelectRecentlyUsedWallet() async {
    final moneySourceProvider = context.read<MoneySourceProvider>();
    if (!moneySourceProvider.hasData) {
      await moneySourceProvider.loadAllMoneySources();
    }
    if (!mounted || moneySourceProvider.moneySources.isEmpty) return;
    if (_selectedWallet != null) return;

    MoneySourceModel? walletToSelect;
    try {
      final response = await _transactionService.getAllTransactions(
        pageSize: 1,
        useCountTotal: false,
      );
      if (response.items.isNotEmpty) {
        final latestWalletId = response.items.first.walletId;
        for (final wallet in moneySourceProvider.moneySources) {
          if (wallet.id == latestWalletId) {
            walletToSelect = wallet;
            break;
          }
        }
      }
    } catch (_) {}

    walletToSelect ??= moneySourceProvider.moneySources.first;
    if (!mounted) return;
    setState(() => _selectedWallet = walletToSelect);
  }

  @override
  void dispose() {
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
              ? 'Quản lý nguồn tiền'
              : 'Manage wallets',
        ),
      ],
      body: MoneySourceSelectorDrawer(
        selectedWallet: _selectedWallet,
        onWalletSelected: (wallet) {
          setState(() => _selectedWallet = wallet);
          Navigator.of(context).pop();
        },
      ),
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return Container(
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
              Center(
                child: TextFormField(
                  controller: _titleController,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
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
              const SizedBox(height: AppSizes.xl),

              // --- Amount Field ---
              _buildFieldRow(
                context,
                label: l10n.amount,
                child: Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.end,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      filled: false,
                      hintText: '0',
                      hintStyle: TextStyle(color: colors.neutralTextDisable),
                      suffixText: ' VND',
                      suffixStyle: TextStyle(
                        color: colors.neutralTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                    validator: _validateAmount,
                  ),
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
                child: Expanded(
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
                          color: colors.neutralTextPrimary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              _buildFieldRow(
                context,
                label: _typeFieldLabel(context),
                child: SegmentedButton<int>(
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
                child: InkWell(
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
                              color: colors.neutralTextDisable,
                            ),
                          ],
                        ),
                ),
              ),

              _buildFieldRow(
                context,
                label: _walletFieldLabel(context),
                child: InkWell(
                  onTap: _showWalletSelector,
                  child: _selectedWallet != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.m,
                            vertical: AppSizes.s,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedWallet!.backgroundColor.withOpacity(
                              0.2,
                            ),
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
                              color: colors.neutralTextDisable,
                            ),
                          ],
                        ),
                ),
              ),

              _buildFieldRow(
                context,
                label: _photoFieldLabel(context),
                child: InkWell(
                  onTap: _pickPhoto,
                  child: Row(
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
                        style: TextStyle(color: colors.neutralTextSecondary),
                      ),
                      if (_selectedPhoto != null) ...[
                        const SizedBox(width: AppSizes.xs),
                        GestureDetector(
                          onTap: () => setState(() => _selectedPhoto = null),
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

              const SizedBox(height: AppSizes.l),

              // --- Note Field ---
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
    required Widget child,
  }) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.l),
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
