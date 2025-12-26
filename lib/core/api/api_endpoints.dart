class ApiEndpoints {
  static const emulatorURL = "http://10.0.2.2";
  static const realdeviceURL = "http://10.0.2.2";

 static const nowDemoDeviceURL = emulatorURL;

  // Base URLs for different services
  static const String authBaseUrl = "$nowDemoDeviceURL:5212/";
  static const String categoryBaseUrl = "$nowDemoDeviceURL:5212/";
  static const String transactionBaseUrl = "$nowDemoDeviceURL:5212/";
  static const String statisticsBaseUrl = "$nowDemoDeviceURL:5212/";
  
  // Default base URL (for ApiClient compatibility)
  static const String baseUrl = authBaseUrl;

  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Auth Endpoints (using authBaseUrl)
  static const String accounts = "${authBaseUrl}Accounts/me";
  static const String register = "${authBaseUrl}Accounts/register";
  static const String login = "${authBaseUrl}Accounts/login";

  // Category Endpoints (using categoryBaseUrl)
  static const String categories = "${categoryBaseUrl}Categories";
  static String categoryById(String id) => "${categoryBaseUrl}Categories/$id";
  static String updateCategoryUrl(String id) => categoryById(id);
  static String deleteCategoryUrl(String id) => categoryById(id);
  static const String createCategory = "${categoryBaseUrl}Categories";
  static const String deleteCategories = "${categoryBaseUrl}Categories";

  // Transaction Endpoints (using transactionBaseUrl)
  static const String transactions = "${transactionBaseUrl}Transactions";
  static String transactionById(String id) => "${transactionBaseUrl}Transactions/$id";
  static String deleteTransactionUrl(String id) => transactionById(id);
  static const String createTransaction = "${transactionBaseUrl}Transactions";

  // Statistics Endpoints (using statisticsBaseUrl)
  static const String statistics = "${statisticsBaseUrl}Statistics";
}
