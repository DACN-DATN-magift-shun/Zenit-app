import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/services/navigation_service.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_drawer.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';
import 'package:zenit/features/setting_childs/money_source_manage/providers/money_source_provider.dart';
import 'package:zenit/features/setting_childs/money_source_manage/widgets/money_source_selector_drawer.dart';

class AddTransactionFormHelpers {
  static bool isVietnamese(BuildContext context) {
    return Localizations.localeOf(context).languageCode.toLowerCase() == 'vi';
  }

  static String walletFieldLabel(BuildContext context) {
    return isVietnamese(context) ? 'Ví' : 'Wallet';
  }

  static String photoFieldLabel(BuildContext context) {
    return isVietnamese(context) ? 'Ảnh' : 'Photo';
  }

  static String typeFieldLabel(BuildContext context) {
    return isVietnamese(context) ? 'Phân loại' : 'Type';
  }

  static String incomeLabel(BuildContext context) {
    return isVietnamese(context) ? 'Thu' : 'Income';
  }

  static String expenseLabel(BuildContext context) {
    return isVietnamese(context) ? 'Chi' : 'Expense';
  }

  static String selectWalletWarning(BuildContext context) {
    return isVietnamese(context)
        ? 'Vui lòng chọn ví cho giao dịch'
        : 'Please select a wallet for this transaction';
  }

  static void showWalletSelector({
    required BuildContext context,
    required MoneySourceModel? selectedWallet,
    required ValueChanged<MoneySourceModel> onWalletSelected,
  }) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    AppDrawer.showAsBottomSheet(
      context: context,
      title: walletFieldLabel(context),
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
                  if (!context.mounted) return;
                  context.read<MoneySourceProvider>().refreshMoneySources();
                });
          },
          icon: Icon(Icons.settings_rounded, color: colors.primaryMain),
          tooltip: isVietnamese(context)
              ? 'Quản lý nguồn tiền'
              : 'Manage wallets',
        ),
      ],
      body: MoneySourceSelectorDrawer(
        selectedWallet: selectedWallet,
        onWalletSelected: onWalletSelected,
      ),
    );
  }

  static bool isCategoryCompatibleWithCurrentType(
    CategoryModel category,
    bool isIncomeTransaction,
  ) {
    final groupType = int.tryParse(category.groupType) ?? 0;
    final isIncomeCategory = groupType == GroupType.income.value;
    return isIncomeTransaction ? isIncomeCategory : !isIncomeCategory;
  }

  static String formatWalletCurrency(int amount) {
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

  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  static Color parseColor(String hexColor) {
    try {
      String hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  static double calculateNoteMaxHeight(BuildContext context) {
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

  static int? parseAmountValue(String value) {
    final normalized = value.replaceAll(',', '').trim();
    if (normalized.isEmpty) {
      return null;
    }

    return int.tryParse(normalized);
  }

  static int selectedAmountValue(TextEditingController amountController) {
    return parseAmountValue(amountController.text) ?? 0;
  }

  static int? loanAmountValue(TextEditingController loanAmountController) {
    return parseAmountValue(loanAmountController.text);
  }

  static int? netTransactionAmount({
    required int transactionAmount,
    required bool collectLaterEnabled,
    required int? loanAmount,
  }) {
    if (transactionAmount <= 0) {
      return null;
    }

    if (!collectLaterEnabled) {
      return transactionAmount;
    }

    if (loanAmount == null) {
      return null;
    }

    return transactionAmount - loanAmount;
  }

  static String loanSummaryText(
    BuildContext context, {
    required int transactionAmount,
    required int? loanAmount,
    required int? remainingAmount,
  }) {
    if (transactionAmount <= 0) {
      return isVietnamese(context)
          ? 'Nhập số tiền giao dịch tổng'
          : 'Enter the total amount first';
    }

    if (loanAmount == null || remainingAmount == null) {
      return isVietnamese(context)
          ? 'Nhập số tiền bạn thu hộ'
          : 'Enter the loan amount to calculate';
    }

    return isVietnamese(context)
        ? 'Số tiền giao dịch còn lại: ${formatWalletCurrency(remainingAmount)}'
        : 'Remaining transaction amount: ${formatWalletCurrency(remainingAmount)}';
  }

  // --- Amount Expression Calculation ---
  static bool isOperator(String char) =>
      char == '+' || char == '-' || char == '*' || char == '/';

  static int precedenceOfOperator(String op) {
    if (op == '+' || op == '-') return 1;
    if (op == '*' || op == '/') return 2;
    return 0;
  }

  static int? applyOperator(int left, int right, String op) {
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

  static int? evaluateExpression(String expression) {
    final normalized = expression.replaceAll(',', '').replaceAll(' ', '');
    if (normalized.isEmpty) return null;

    if (normalized.startsWith('-') || isOperator(normalized[0])) {
      return null;
    }
    if (isOperator(normalized[normalized.length - 1])) {
      return null;
    }

    final values = <int>[];
    final operators = <String>[];
    int i = 0;

    while (i < normalized.length) {
      final char = normalized[i];

      if (isOperator(char)) {
        while (operators.isNotEmpty &&
            precedenceOfOperator(operators.last) >=
                precedenceOfOperator(char)) {
          if (values.length < 2) return null;
          final right = values.removeLast();
          final left = values.removeLast();
          final result = applyOperator(left, right, operators.removeLast());
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
      final result = applyOperator(left, right, operators.removeLast());
      if (result == null) return null;
      values.add(result);
    }

    return values.length == 1 ? values.first : null;
  }

  static String formatNumberWithCommas(int value) {
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
}
