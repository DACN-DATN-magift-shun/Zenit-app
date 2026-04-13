import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/network/api_client.dart';

class AccountService {
  final _api = ApiClient();

  Future<Response> register({
    required String username,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    return await _api.post(
      ApiEndpoints.register,
      data: {
        "username": username,
        "email": email,
        "phone": phone,
        "address": address,
        "password": password,
      },
    );
  }

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await _api.post(
      ApiEndpoints.login,
      data: {"email": email, "password": password},
    );
  }

  Future<Response> getAccount() async {
    return await _api.get(ApiEndpoints.accounts);
  }

  Future<Response> updateAccount(String id, Map<String, dynamic> data) async {
    return await _api.put(ApiEndpoints.accounts, data: data);
  }

  Future<Response> updateMyAccount({
    required String phone,
    required String address,
    String? photoId,
  }) async {
    final data = <String, dynamic>{"phone": phone, "address": address};
    if (photoId != null && photoId.isNotEmpty) {
      data['photoId'] = photoId;
    }

    return await _api.patch(ApiEndpoints.accounts, data: data);
  }

  Future<Response> deleteAccount(String id) async {
    return await _api.delete(ApiEndpoints.accounts);
  }

  Future<Response> sendOtp({required String email}) async {
    return await _api.post(ApiEndpoints.sendOtp, data: {"email": email});
  }

  Future<Response> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return await _api.post(
      ApiEndpoints.verifyOtp,
      data: {"email": email, "otp": otp},
    );
  }

  Future<Response> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    return await _api.post(
      ApiEndpoints.resetPassword,
      data: {"resetToken": resetToken, "newPassword": newPassword},
    );
  }
}
