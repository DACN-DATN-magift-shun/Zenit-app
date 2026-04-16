import 'package:flutter/material.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';

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
}
