class MoneySourceManageFormValidator {
  static String? moneySourceName(String? value, {required bool isVietnamese}) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return isVietnamese
          ? 'Vui lòng nhập tên nguồn tiền'
          : 'Please enter money source name';
    }

    if (text.length > 25) {
      return isVietnamese
          ? 'Tên nguồn tiền không được vượt quá 25 ký tự'
          : 'Money source name must not exceed 25 characters';
    }

    return null;
  }

  static String? amount(String? value, {required String invalidAmountMessage}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }

    final parsedAmount = int.tryParse(text);
    if (parsedAmount == null) {
      return invalidAmountMessage;
    }

    return null;
  }
}
