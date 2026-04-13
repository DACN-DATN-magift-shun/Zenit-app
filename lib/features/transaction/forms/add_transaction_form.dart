import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/services/navigation_service.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_flash.dart';
import 'package:zenit/core/widgets/app_drawer.dart';
import 'package:zenit/features/transaction/widgets/category_selector_drawer.dart';
import 'package:zenit/features/transaction/services/transaction_service.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';
import 'package:zenit/features/setting_childs/money_source_manage/providers/money_source_provider.dart';

/// Data class chứa thông tin transaction từ form
class TransactionFormData {
  final String title;
  final String note;
  final int amount;
  final DateTime transactionDate;
  final String categoryId;
  final String walletId;
  final XFile? photoFile;

  TransactionFormData({
    required this.title,
    required this.note,
    required this.amount,
    required this.transactionDate,
    required this.categoryId,
    required this.walletId,
    this.photoFile,
  });
}

class AddTransactionForm extends StatefulWidget {
  /// Callback khi form sẵn sàng, trả về hàm validate và lấy data
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
  final _noteController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  DateTime _selectedDate = DateTime.now();
  CategoryModel? _selectedCategory;
  MoneySourceModel? _selectedWallet;
  XFile? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = context.read<CategoryProvider>();

      if (!categoryProvider.hasData) {
        categoryProvider.loadAllCategories();
      }

      _autoSelectRecentlyUsedWallet();

      // Expose getFormData function to parent
      widget.onFormReady?.call(_getFormData);
    });
  }

  Future<void> _autoSelectRecentlyUsedWallet() async {
    final moneySourceProvider = context.read<MoneySourceProvider>();

    if (!moneySourceProvider.hasData) {
      await moneySourceProvider.loadAllMoneySources();
    }

    if (!mounted || moneySourceProvider.moneySources.isEmpty) {
      return;
    }

    if (_selectedWallet != null) {
      return;
    }

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
    } catch (_) {
      // Keep silent and fall back to first available wallet.
    }

    walletToSelect ??= moneySourceProvider.moneySources.first;

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedWallet = walletToSelect;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
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
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(
                context,
              ).extension<AppColorExtension>()!.primaryMain,
              onPrimary: Colors.white, // Dùng Color.white theo yêu cầu
              surface: Colors.white,
              onSurface: Theme.of(
                context,
              ).extension<AppColorExtension>()!.neutralTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
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

  void _showCategorySelector() {
    final colors = Theme.of(context).extension<AppColorExtension>()!;

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
        onCategorySelected: (category) {
          setState(() {
            _selectedCategory = category;
          });
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
              ? 'Quan ly nguon tien'
              : 'Manage wallets',
        ),
      ],
      body: Consumer<MoneySourceProvider>(
        builder: (context, moneySourceProvider, child) {
          if (moneySourceProvider.isLoading &&
              moneySourceProvider.moneySources.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (moneySourceProvider.moneySources.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.l),
                child: Text(
                  _isVietnamese(context)
                      ? 'Chua co vi nao. Hay tao vi trong cai dat.'
                      : 'No wallet found. Please create one in settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.neutralTextSecondary),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.l),
            itemCount: moneySourceProvider.moneySources.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.s),
            itemBuilder: (context, index) {
              final wallet = moneySourceProvider.moneySources[index];
              final isSelected = _selectedWallet?.id == wallet.id;
              return _buildWalletOptionTile(
                context,
                wallet: wallet,
                isSelected: isSelected,
              );
            },
          );
        },
      ),
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
        setState(() {
          _selectedWallet = wallet;
        });
        Navigator.of(context).pop();
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
    return _isVietnamese(context) ? 'Khong co ghi chu' : 'No note';
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Color _parseColor(String hexColor) {
    try {
      String hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
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

  TransactionFormData? _getFormData() {
    if (!_formKey.currentState!.validate()) {
      return null;
    }

    if (_selectedCategory == null) {
      AppFlash.warning(context, context.l10n.selectCategoryWarning);
      return null;
    }

    if (_selectedWallet == null) {
      AppFlash.warning(context, _selectWalletWarning(context));
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
    );
  }

  bool _isVietnamese(BuildContext context) {
    return Localizations.localeOf(context).languageCode.toLowerCase() == 'vi';
  }

  String _walletFieldLabel(BuildContext context) {
    return _isVietnamese(context) ? 'Vi' : 'Wallet';
  }

  String _photoFieldLabel(BuildContext context) {
    return _isVietnamese(context) ? 'Anh' : 'Photo';
  }

  String _selectWalletWarning(BuildContext context) {
    return _isVietnamese(context)
        ? 'Vui long chon vi cho giao dich'
        : 'Please select a wallet for this transaction';
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.transactionName;
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.enterAmount;
    }

    final amount = int.tryParse(value.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      return context.l10n.enterValidAmount;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final noteMaxHeight = _calculateNoteMaxHeight(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white, // Dùng Color.white
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
                    color: colors.neutralTextSecondary,
                  ),
                  decoration: InputDecoration(
                    filled: false,
                    fillColor: Colors.transparent,
                    hintText: l10n.transactionName,
                    hintStyle: TextStyle(
                      color: colors.neutralTextDisable.withOpacity(0.5),
                      fontWeight: FontWeight.w700,
                    ),
                    border: InputBorder.none,
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
                    decoration: InputDecoration(
                      filled: false,
                      fillColor: Colors.transparent,
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

              // --- Time Field ---
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
                              : _formatDate(
                                  _selectedDate,
                                ), // Logic hiển thị 'Today' nếu muốn
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

              // --- Category Field ---
              _buildFieldRow(
                context,
                label: l10n.singleCategory,
                child: InkWell(
                  onTap: _showCategorySelector,
                  borderRadius: BorderRadius.circular(
                    AppSizes.borderRadiusXSmall,
                  ),
                  child: _selectedCategory != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.m,
                            vertical: AppSizes.s,
                          ),
                          decoration: BoxDecoration(
                            color: _parseColor(
                              _selectedCategory!.backgroundColor,
                            ).withOpacity(0.2), // Màu nền nhẹ
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
                                  color: _parseColor(
                                    _selectedCategory!.color,
                                  ), // Màu chữ đậm
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Symbols.sell_rounded,
                                size: 16,
                                color: _parseColor(_selectedCategory!.color),
                              ),
                            ],
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
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
                  borderRadius: BorderRadius.circular(
                    AppSizes.borderRadiusXSmall,
                  ),
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
                          mainAxisSize: MainAxisSize.min,
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
                                  ? 'Chon anh'
                                  : 'Choose photo'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.neutralTextSecondary),
                      ),
                      if (_selectedPhoto != null) ...[
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
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: 88,
                      maxHeight: noteMaxHeight,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadiusMedium,
                      ),
                    ),
                    child: TextFormField(
                      controller: _noteController,
                      minLines: 1,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        hintText: '',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(AppSizes.m),
                      ),
                    ),
                  ),
                ],
              ),

              // Bỏ cái nút Submit to đùng ở dưới đi vì đã có nút ở góc trên
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
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.s,
      ), // Giảm padding dọc chút cho gọn
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
          child, // Widget con (Input, DatePicker, Category) sẽ nằm bên phải
        ],
      ),
    );
  }
}
