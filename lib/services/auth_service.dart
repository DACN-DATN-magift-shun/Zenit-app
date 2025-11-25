import 'package:dio/dio.dart';
import 'package:zenit/data/local/storage_service.dart';
import 'package:zenit/services/account_service.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _accountService = AccountService();

  // Kiểm tra xem user đã đăng nhập chưa
  Future<bool> isAuthenticated() async {
    final token = await StorageService().getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Lấy access token
  Future<String?> getAccessToken() async {
    return await StorageService().getAccessToken();
  }

  // Lấy user ID
  Future<String?> getUserId() async {
    return await StorageService().getUserId();
  }

  // Lấy thông tin user từ API
  Future<Response?> getUserInfo() async {
    try {
      // API now returns current user without requiring an ID
      final response = await _accountService.getAccount();
      return response;
    } catch (e) {
      print('Error fetching user info: $e');
      return null;
    }
  }

  // Lấy tên user để hiển thị (fallback về "User" nếu không có)
  Future<String> getUserDisplayName() async {
    try {
      final response = await getUserInfo();
      if (response == null) return 'User';
      
      // Truy cập data từ response
      final data = response.data;
      final userInfo = data['data'] as Map<String, dynamic>? ?? data as Map<String, dynamic>?;
      return userInfo?['username'] as String? ?? 'User';
    } catch (e) {
      print('Error getting user display name: $e');
      return 'User';
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    await StorageService().clearStorageAll();
  }

  // Lưu thông tin đăng nhập
  Future<void> saveLoginData({
    required String accessToken,
    required String refreshToken,
  }) async {
    await StorageService().saveToken(accessToken, refreshToken);
  }

  // Lưu thông tin đăng ký
  Future<void> saveSignupData({
    required String userId,
  }) async {
    await StorageService().saveUserId(userId);
  }
}