import 'package:flutter/material.dart';
import 'package:zenit/core/l10n/l10n.dart';

class AddTransactionFormValidators {
  static String? validateTitle(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.transactionName;
    }
    return null;
  }

  static String? validateAmount(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.enterAmount;
    }

    final amount = int.tryParse(value.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      return context.l10n.enterValidAmount;
    }

    return null;
  }

  static String? validateLoanAmountField(
    BuildContext context, {
    required bool collectLaterEnabled,
    required String? value,
    required int transactionAmount,
    required bool isVietnamese,
  }) {
    if (!collectLaterEnabled) {
      return null;
    }

    if (value == null || value.trim().isEmpty) {
      return isVietnamese
          ? 'Số tiền khoản vay không được để trống'
          : 'Loan amount is required';
    }

    final loanAmount = int.tryParse(value.trim());
    if (loanAmount == null || loanAmount <= 0) {
      return isVietnamese
          ? 'Số tiền khoản vay phải lớn hơn 0'
          : 'Loan amount must be greater than 0';
    }

    if (transactionAmount <= 0 || loanAmount >= transactionAmount) {
      return isVietnamese
          ? 'Khoản vay phải nhỏ hơn số tiền giao dịch'
          : 'Loan amount must be less than the transaction amount';
    }

    return null;
  }

  static String? validateCollectLaterRule({
    required bool collectLaterEnabled,
    required int transactionAmount,
    required int? loanAmount,
    required DateTime loanDueDate,
    required DateTime transactionDate,
    required bool isVietnamese,
  }) {
    if (!collectLaterEnabled) {
      return null;
    }

    if (loanAmount == null || loanAmount <= 0) {
      return isVietnamese
          ? 'Vui lòng nhập số tiền khoản vay hợp lệ'
          : 'Please enter a valid loan amount';
    }

    if (loanAmount >= transactionAmount) {
      return isVietnamese
          ? 'Khoản vay phải nhỏ hơn số tiền giao dịch'
          : 'Loan amount must be less than the transaction amount';
    }

    if (loanDueDate.isBefore(transactionDate)) {
      return isVietnamese
          ? 'Ngày đến hạn phải lớn hơn hoặc bằng ngày giao dịch'
          : 'Due date must be greater than or equal to the transaction date';
    }

    return null;
  }
}
