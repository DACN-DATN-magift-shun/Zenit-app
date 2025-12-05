import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/utils/validators/transactions_form_validator.dart';
import 'package:zenit/core/widgets/app_drawer.dart';
import 'package:zenit/features/home_childs/transaction/widgets/category_selector_drawer.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';

/// Data class chứa thông tin transaction từ form
class TransactionFormData {
  final String title;
  final String note;
  final int amount;
  final DateTime transactionDate;
  final String categoryId;

  TransactionFormData({
    required this.title,
    required this.note,
    required this.amount,
    required this.transactionDate,
    required this.categoryId,
  });
}

class AddTransactionForm extends StatefulWidget {
  /// Callback khi form sẵn sàng, trả về hàm validate và lấy data
  final Function(TransactionFormData? Function() getFormData)? onFormReady;

  const AddTransactionForm({
    super.key,
    this.onFormReady,
  });

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = context.read<CategoryProvider>();
      if (!categoryProvider.hasData) {
        categoryProvider.loadAllCategories();
      }
      // Expose getFormData function to parent
      widget.onFormReady?.call(_getFormData);
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
              primary: Theme.of(context).extension<AppColorExtension>()!.primaryMain,
              onPrimary: Colors.white, // Dùng Color.white theo yêu cầu
              surface: Colors.white,
              onSurface: Theme.of(context).extension<AppColorExtension>()!.neutralTextPrimary,
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

  void _showCategorySelector() {
    AppDrawer.showAsBottomSheet(
      context: context,
      title: 'Choose a tag for transaction',
      showCloseButton: false,
      showDragHandle: true,
      height: MediaQuery.of(context).size.height * 0.85,
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

  TransactionFormData? _getFormData() {
    if (!_formKey.currentState!.validate()) {
      return null;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.orange,
        ),
      );
      return null;
    }

    return TransactionFormData(
      title: _titleController.text.trim(),
      note: _noteController.text.trim(),
      amount: int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0,
      transactionDate: _selectedDate,
      categoryId: _selectedCategory!.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;

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
                    hintText: 'Transaction name',
                    hintStyle: TextStyle(
                      color: colors.neutralTextDisable.withOpacity(0.5),
                      fontWeight: FontWeight.w700,
                    ),
                    border: InputBorder.none, 
                    contentPadding: EdgeInsets.zero,
                  ),
                  // Gọi Validator ở đây
                  validator: TransactionValidator.validateTitle,
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // --- Amount Field ---
              _buildFieldRow(
                context,
                label: 'Amount',
                child: Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
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
                    validator: TransactionValidator.validateAmount,
                  ),
                ),
              ),

              // --- Time Field ---
              _buildFieldRow(
                context,
                label: 'Time',
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
                              ? 'Today'
                              : _formatDate(_selectedDate), // Logic hiển thị 'Today' nếu muốn
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
                label: '(Single) Category',
                child: InkWell(
                  onTap: _showCategorySelector,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall),
                  child: _selectedCategory != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.m,
                            vertical: AppSizes.s,
                          ),
                          decoration: BoxDecoration(
                            color: _parseColor(_selectedCategory!.backgroundColor).withOpacity(0.2), // Màu nền nhẹ
                            borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedCategory!.name,
                                style: TextStyle(
                                  color: _parseColor(_selectedCategory!.color), // Màu chữ đậm
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
                              'Select',
                              style: TextStyle(color: colors.neutralTextDisable),
                            ),
                             Icon(Icons.chevron_right, color: colors.neutralTextDisable),
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
                    'Note',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: colors.neutralTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.s),
                  Container(
                    height: 120, // Chiều cao cố định hoặc để auto
                    decoration: BoxDecoration(
                      color: colors.neutralBackground, // Màu xám nền
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
                    ),
                    child: TextFormField(
                      controller: _noteController,
                      maxLines: null, // Cho phép xuống dòng
                      decoration: InputDecoration(
                        hintText: '',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(AppSizes.m),
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

  Widget _buildFieldRow(BuildContext context, {
    required String label,
    required Widget child,
  }) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s), // Giảm padding dọc chút cho gọn
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