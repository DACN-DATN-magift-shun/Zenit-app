import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:zenit/data/local/storage_service.dart';
import 'package:zenit/features/auth/services/account_service.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _accountService = AccountService();
  final _storageService = StorageService();

  // Kiểm tra xem user đã đăng nhập chưa
  Future<bool> isAuthenticated() async {
    final token = await _storageService.getAccessToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    if (_isTokenExpired(token)) {
      await _storageService.clearStorage();
      return false;
    }

    return true;
  }

  // Lấy access token
  Future<String?> getAccessToken() async {
    return await _storageService.getAccessToken();
  }

  // Lấy user ID
  Future<String?> getUserId() async {
    return await _storageService.getUserId();
  }

  // Lấy thông tin user từ API
  Future<Response?> getUserInfo() async {
    try {
      // API now returns current user without requiring an ID
      final response = await _accountService.getAccount();
      return response;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _storageService.clearStorage();
      }
      print('Error fetching user info: ${e.message}');
      return null;
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

      dynamic payload = response.data;
      if (payload is String && payload.isNotEmpty) {
        try {
          payload = jsonDecode(payload);
        } catch (_) {
          return 'User';
        }
      }

      Map<String, dynamic>? root;
      if (payload is Map<String, dynamic>) {
        root = payload;
      } else if (payload is Map) {
        root = Map<String, dynamic>.from(payload);
      }
      if (root == null) return 'User';

      dynamic userData = root['data'];
      if (userData is String && userData.isNotEmpty) {
        try {
          userData = jsonDecode(userData);
        } catch (_) {
          userData = null;
        }
      }

      Map<String, dynamic>? userInfo;
      if (userData is Map<String, dynamic>) {
        userInfo = userData;
      } else if (userData is Map) {
        userInfo = Map<String, dynamic>.from(userData);
      } else if (userData is List && userData.isNotEmpty && userData.first is Map) {
        userInfo = Map<String, dynamic>.from(userData.first as Map);
      } else {
        userInfo = root;
      }

      final username = userInfo['username'];
      if (username is String && username.isNotEmpty) {
        return username;
      }
      return 'User';
    } catch (e) {
      print('Error getting user display name: $e');
      return 'User';
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    await _storageService.clearStorageAll();
  }

  // Lưu thông tin đăng nhập
  Future<void> saveLoginData({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storageService.saveToken(accessToken, refreshToken);
  }

  // Lưu thông tin đăng ký
  Future<void> saveSignupData({
    required String userId,
  }) async {
    await _storageService.saveUserId(userId);
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return false;
      }

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final payloadMap = jsonDecode(payload) as Map<String, dynamic>;
      final exp = payloadMap['exp'];

      if (exp is! int) {
        return false;
      }

      final nowInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp <= nowInSeconds;
    } catch (_) {
      return false;
    }
  }
}