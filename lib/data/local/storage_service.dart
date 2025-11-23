import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String accessTokenKey = 'ACCESS_TOKEN';
  static const String refreshTokenKey = 'REFRESH_TOKEN';
  static const String userIdKey = 'USER_ID';

  Future<void> saveToken (String access, String refresh) async{
      await _secureStorage.write(key: accessTokenKey, value: access);
      await _secureStorage.write(key: refreshTokenKey, value: refresh);
  }
  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: userIdKey, value: userId);
  }
  
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: userIdKey);
  }
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: accessTokenKey);
  }
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: refreshTokenKey);
  }

  Future<void> clearStorage() async{
    await _secureStorage.delete(key: accessTokenKey);
    await _secureStorage.delete(key: refreshTokenKey);
  }

}