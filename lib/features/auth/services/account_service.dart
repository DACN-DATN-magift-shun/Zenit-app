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
  }) async {
    return await _api.patch(
      ApiEndpoints.accounts,
      data: {
        "phone": phone,
        "address": address,
      },
    );
  }

  Future<Response> deleteAccount(String id) async {
    return await _api.delete(ApiEndpoints.accounts);
  }

  Future<Response> sendOtp({
    required String email,
    String? phoneNumber,
  }) async {
    return await _api.post(
      ApiEndpoints.sendOtp,
      data: {
        "email": email,
        "phoneNumber": phoneNumber ?? "",
      },
    );
  }

  Future<Response> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    return await _api.post(
      ApiEndpoints.verifyOtp,
      data: {
        "email": email,
        "otpCode": otpCode,
      },
    );
  }

  Future<Response> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await _api.post(
      ApiEndpoints.resetPassword,
      data: {
        "email": email,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      },
    );
  }
}