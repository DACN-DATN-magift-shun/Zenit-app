class ApiEndpoints {
  static const String localBaseUrl = "http://10.0.2.2:5212/";
  static const String productionBaseUrl =
      "https://zenit-api-tuir.onrender.com/";

  // Toggle this when switching between local backend and deployed backend.
  static const bool useProduction = true;
  static const String nowDemoDeviceURL = useProduction
      ? productionBaseUrl
      : localBaseUrl;

  // Base URLs for different services
  static const String authBaseUrl = nowDemoDeviceURL;
  static const String categoryBaseUrl = nowDemoDeviceURL;
  static const String transactionBaseUrl = nowDemoDeviceURL;
  static const String statisticsBaseUrl = nowDemoDeviceURL;

  // Default base URL (for ApiClient compatibility)
  static const String baseUrl = authBaseUrl;

  static const int connectionTimeout = 60000;
  static const int receiveTimeout = 60000;

  // Auth Endpoints (using authBaseUrl)
  static const String accounts = "${authBaseUrl}Accounts/me";
  static const String register = "${authBaseUrl}Accounts/register";
  static const String login = "${authBaseUrl}Accounts/login";
  static const String sendOtp = "${authBaseUrl}Accounts/send-otp";
  static const String verifyOtp = "${authBaseUrl}Accounts/verify-otp";
  static const String resetPassword = "${authBaseUrl}Accounts/reset-password";

  // Category Endpoints (using categoryBaseUrl)
  static const String categories = "${categoryBaseUrl}Categories";
  static String categoryById(String id) => "${categoryBaseUrl}Categories/$id";
  static String updateCategoryUrl(String id) => categoryById(id);
  static String deleteCategoryUrl(String id) => categoryById(id);
  static const String createCategory = "${categoryBaseUrl}Categories";
  static const String deleteCategories = "${categoryBaseUrl}Categories";

  // Transaction Endpoints (using transactionBaseUrl)
  static const String transactions = "${transactionBaseUrl}Transactions";
  static String transactionById(String id) =>
      "${transactionBaseUrl}Transactions/$id";
  static String deleteTransactionUrl(String id) => transactionById(id);
  static const String createTransaction = "${transactionBaseUrl}Transactions";

  // Wallet Endpoints (using transactionBaseUrl)
  static const String wallets = "${transactionBaseUrl}Wallets";
  static String walletById(String id) => "${transactionBaseUrl}Wallets/$id";
  static String updateWalletUrl(String id) => walletById(id);
  static String deleteWalletUrl(String id) => walletById(id);
  static const String createWallet = "${transactionBaseUrl}Wallets";

  // Loans Endpoints (using transactionBaseUrl)
  static const String loans = "${transactionBaseUrl}Loans";
  static String loanById(String id) => "${transactionBaseUrl}Loans/$id";
  static String updateLoanUrl(String id) => loanById(id);
  static String deleteLoanUrl(String id) => loanById(id);
  static const String createLoan = "${transactionBaseUrl}Loans";
  static const String createManyLoans = "${transactionBaseUrl}Loans/many";

  // Money transfer endpoints (using transactionBaseUrl)
  static const String moneyTransfers = "${transactionBaseUrl}MoneyTransfers";
  static String moneyTransferById(String id) =>
      "${transactionBaseUrl}MoneyTransfers/$id";
  static String updateMoneyTransferUrl(String id) => moneyTransferById(id);
  static String deleteMoneyTransferUrl(String id) => moneyTransferById(id);
  static const String createMoneyTransfer =
      "${transactionBaseUrl}MoneyTransfers";

  // Statistics Endpoints (using statisticsBaseUrl)
  static const String statistics = "${statisticsBaseUrl}Statistics";

  // Photos Endpoints (using transactionBaseUrl)
  static const String photos = "${transactionBaseUrl}Photos";
  static String photoById(String id) => "${transactionBaseUrl}Photos/$id";
}
