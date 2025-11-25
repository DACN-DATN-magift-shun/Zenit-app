class ApiEndpoints {
  // static const String baseUrl = "http://localhost:5241/";
  // url for emulator
  static const String baseUrl = "http://10.0.2.2:5241/";

  // url for real device testing in local network
  // static const String baseUrl = "http://192.168.151.211:5241/";
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  static const String accounts = "${baseUrl}Accounts/me";
  static const String register = "${baseUrl}Accounts/register";
  static const String login = "${baseUrl}Accounts/login";
  // static String accountInfor() => "${baseUrl}Accounts/me";
}
