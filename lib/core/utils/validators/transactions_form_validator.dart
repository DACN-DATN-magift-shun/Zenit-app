
class TransactionValidator {
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter transaction name';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter amount';
    }
    final amount = int.tryParse(value.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }
    return null;
  }
}