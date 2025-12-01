import 'package:dio/dio.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/local/storage_service.dart';

class ApiClient {
  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;
  final StorageService _storageService = StorageService();
  // bool _isRefreshing = false;

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

      // 2. Response Interceptor: Xử lý lỗi 401 và Refresh Token 
      // onError: (DioException error, handler) async {
      //   if (error.response?.statusCode == 401) {
      //     // Nếu server báo 401 Unauthorized
      //     if (!_isRefreshing) {
      //       _isRefreshing = true;
      //       try {
      //         final refreshToken = await _storageService.getRefreshToken(); //
              
      //         if (refreshToken != null) {
      //           // Gọi API refresh token
      //           final response = await _dio.post(ApiEndpoints.refresh, data: {
      //             'refreshToken': refreshToken,
      //           });

      //           final newAccessToken = response.data['data']['accessToken']; 
      //           final newRefreshToken = response.data['data']['refreshToken'];

      //           // Lưu token mới
      //           await _storageService.saveToken(newAccessToken, newRefreshToken);
                
      //           // Retry request cũ với token mới
      //           _isRefreshing = false;
      //           final opts = error.requestOptions;
      //           opts.headers['Authorization'] = 'Bearer $newAccessToken';
                
      //           final clonedRequest = await _dio.request(
      //             opts.path,
      //             options: Options(
      //               method: opts.method,
      //               headers: opts.headers,
      //             ),
      //             data: opts.data,
      //             queryParameters: opts.queryParameters,
      //           );
                
      //           return handler.resolve(clonedRequest);
      //         }
      //       } catch (e) {
      //         // Refresh thất bại -> Logout 
      //         _isRefreshing = false;
      //         await _storageService.clearStorage();
      //         // TODO: Điều hướng về màn hình Login (dùng NavigationService)
      //         print("Phiên đăng nhập hết hạn, vui lòng login lại");
      //       }
      //     }
      //   }
      //   return handler.next(error); // [cite: 11]
      // },
    ));
  }
}