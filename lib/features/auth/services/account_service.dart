import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/network/api_client.dart';

class AccountService {
  final _apiClient = ApiClient();


  Future<Response> register({
    required String username,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    return await _apiClient.dio.post(
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
    return await _apiClient.dio.post(
      ApiEndpoints.login,
      data: {"email": email, "password": password},
    );
  }

  // API changed: fetching current account no longer requires an ID parameter
  Future<Response> getAccount() async {
    return await _apiClient.dio.get(
      ApiEndpoints.accounts,
    );
  }

  Future<Response> updateAccount(String id, Map<String, dynamic> data) async {
    return await _apiClient.dio.put(
      ApiEndpoints.accounts,
      data: data,
    );
  }

  Future<Response> deleteAccount(String id) async {
    return await _apiClient.dio.delete(ApiEndpoints.accounts);
  }
}