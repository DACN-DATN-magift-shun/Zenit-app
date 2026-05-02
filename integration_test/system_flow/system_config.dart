import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/local/storage_service.dart';

class SystemFlowConfig {
  SystemFlowConfig._();

  static const String backendBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: ApiEndpoints.productionBaseUrl,
  );

  static const String loginEmail = String.fromEnvironment(
    'SYSTEM_TEST_EMAIL',
    defaultValue: 'tester@example.com',
  );

  static const String loginPassword = String.fromEnvironment(
    'SYSTEM_TEST_PASSWORD',
    defaultValue: 'Passw0rd!',
  );

  static const String transactionTitle = String.fromEnvironment(
    'SYSTEM_TEST_TRANSACTION_TITLE',
    defaultValue: 'System flow lunch',
  );

  static const String transactionNote = String.fromEnvironment(
    'SYSTEM_TEST_TRANSACTION_NOTE',
    defaultValue: 'System flow test',
  );

  static const String transactionAmount = String.fromEnvironment(
    'SYSTEM_TEST_TRANSACTION_AMOUNT',
    defaultValue: '120000',
  );

  static const String initialWalletName = String.fromEnvironment(
    'SYSTEM_TEST_INITIAL_WALLET_NAME',
    defaultValue: 'Cash',
  );

  static const String targetWalletName = String.fromEnvironment(
    'SYSTEM_TEST_TARGET_WALLET_NAME',
    defaultValue: 'Bank',
  );

  static const String categoryName = String.fromEnvironment(
    'SYSTEM_TEST_CATEGORY_NAME',
    defaultValue: 'Food',
  );

  static const String transactionSuccessMessage =
      'Transaction added successfully!';
  static const String logoutSuccessMessage = 'Logged out successfully';

  static Map<String, String?> initialStorage() {
    return <String, String?>{
      StorageService.languageCodeKey: 'en',
    };
  }
}