import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/core/services/navigation_service.dart';
import 'package:zenit/data/local/storage_service.dart';

class ApiClient {
  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;
  final StorageService _storageService = StorageService();
  bool _isHandlingUnauthorized = false;

  // Khởi tạo Dio KHÔNG có baseUrl cố định - để hỗ trợ nhiều service với base URL khác nhau
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: ApiEndpoints.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: ApiEndpoints.receiveTimeout),
      headers: {'Content-Type': 'application/json'},
    ));

    _setupInterceptors();
  }

  Dio get dio => _dio;

  // ============ CONVENIENCE METHODS ============
  // Dùng các method này để gọi API với full URL từ ApiEndpoints

  Future<Response<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(url, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(url, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> put<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(url, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> delete<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(url, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> patch<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch<T>(url, data: data, queryParameters: queryParameters, options: options);
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      // 1. Request Interceptor: Tự động gắn Token vào header
      onRequest: (options, handler) async {
        final token = await _storageService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },

      // 2. Response Interceptor: khi token hết hạn thì xóa session và về màn login.
      onError: (DioException error, handler) async {
        final statusCode = error.response?.statusCode;
        final requestPath = error.requestOptions.path;

        if (statusCode == 401 && !_isAuthEndpoint(requestPath)) {
          await _storageService.clearStorage();

          if (!_isHandlingUnauthorized) {
            _isHandlingUnauthorized = true;
            NavigationService.instance.pushAndRemoveUntil(
              '/login',
              arguments: {
                'snackMessage': 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
              },
            );
            _isHandlingUnauthorized = false;
          }
        }

        return handler.next(error);
      },
    ));
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('Accounts/login') ||
        path.contains('Accounts/register') ||
        path.contains('Accounts/send-otp') ||
        path.contains('Accounts/verify-otp') ||
        path.contains('Accounts/reset-password');
  }
}