class ApiEndpoints {
  // static const String localBaseUrl = "http://192.168.1.44:5212/";
  static const String localBaseUrl = "http://10.0.2.2:5212/";
  static const String productionBaseUrl =
      "https://zenit-api-tuir.onrender.com/";

  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  // Toggle this when switching between local backend and deployed backend. False for local development, true for production deployment. Can also be overridden by setting the USE_PRODUCTION environment variable

  static const bool useProduction = bool.fromEnvironment(
    'USE_PRODUCTION',
    defaultValue: true,
  );

  static const String demoURL = _apiBaseUrlOverride != ''
      ? _apiBaseUrlOverride
      : (useProduction ? productionBaseUrl : localBaseUrl);

  // Base URLs for different services
  static const String authBaseUrl = demoURL;
  static const String categoryBaseUrl = demoURL;
  static const String transactionBaseUrl = demoURL;
  static const String statisticsBaseUrl = demoURL;

  // Default base URL (for ApiClient compatibility)
  static const String baseUrl = authBaseUrl;

  // Increased timeouts for long-running chatbot responses (milliseconds)
  static const int connectionTimeout = 180000; // 3 minutes
  static const int receiveTimeout = 180000; // 3 minutes

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

  // Goals Endpoints (using transactionBaseUrl)
  static const String goals = "${transactionBaseUrl}Goals";
  static String goalById(String id) => "${transactionBaseUrl}Goals/$id";
  static String updateGoalUrl(String id) => goalById(id);
  static String deleteGoalUrl(String id) => goalById(id);
  static const String createGoal = "${transactionBaseUrl}Goals";

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
  static const String statisticsReports =
      "${statisticsBaseUrl}Statistics/reports";

  // Photos Endpoints (using transactionBaseUrl)
  static const String photos = "${transactionBaseUrl}Photos";
  static String photoById(String id) => "${transactionBaseUrl}Photos/$id";

  // Conversation Endpoints (using baseUrl)
  static const String conversations = "${baseUrl}Conversations";
  static String conversationById(String id) => "${baseUrl}Conversations/$id";

  // Message Endpoints (using baseUrl)
  static const String messages = "${baseUrl}Messages";
}