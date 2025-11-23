import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
// Check lại đường dẫn import cho đúng dự án của mày nha
import 'package:zenit/common/constants/api_endpoints.dart';
import 'package:zenit/common/layout/auth_layout.dart';
import 'package:zenit/common/utils/services/navigation_service.dart';
import 'package:zenit/common/widgets/forms/login_form.dart';
import 'package:zenit/data/local/storage_service.dart';
import 'package:zenit/data/network/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleLogin(String email, String password) async {
    // =========================================================================
    // [DEBUG CONFIG] Bật/Tắt chế độ soi API tại đây
    // true = In log, hiện delay 10s. false = Chạy mượt như người dùng thật.
    const bool isDebugMode = true; 
    // =========================================================================

    setState(() => _isLoading = true);

    try {
      if (isDebugMode) print('>>> [DEBUG] Đang gọi API Login...');

      final response = await ApiClient().dio.post(
        ApiEndpoints.login,
        data: {"email": email, "password": password},
      );

      // Lấy data an toàn
      final responseData = response.data['data'] ?? response.data;
      final accessToken = responseData['accessToken'];
      final refreshToken = responseData['refreshToken'];
      final userID = responseData['id'];

      // =========================== KHỐI DEBUG (BẮT ĐẦU) ===========================
      // Phần này chỉ chạy khi mày đang test, code production không bị ảnh hưởng
      if (isDebugMode) {
        print('\n------------------- API RESPONSE LOG -------------------');
        print('Status Code: ${response.statusCode}');
        print('Full Data: ${response.data}');
        
        if (accessToken != null) {
          print('✅ Access Token: $accessToken');
          print('✅ Refresh Token: $refreshToken');
          print('✅ User ID: $userID');
          print('⏳ Đang delay 10s để mày kịp soi log (Đừng tắt app)...');
          
          // Giả lập delay để soi log
          await Future.delayed(const Duration(seconds: 10));
          print('🚀 Hết giờ! Chuyển màn hình...');
        } else {
          print('❌ Lỗi: Không thấy token trong response!');
        }
        print('--------------------------------------------------------\n');
      }
      // ============================ KHỐI DEBUG (KẾT THÚC) ===========================

      if (accessToken != null && refreshToken != null) {
        // Lưu token (Logic chính)
        await StorageService().saveToken(accessToken, refreshToken);
        await StorageService().saveUserId(userID);
        // Điều hướng
        if (mounted) {
          NavigationService.instance.navigateTo('/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(response.data['message'] ?? 'Dữ liệu trả về lỗi'))
          );
        }
      }

    } on DioException catch (e) {
      // Vẫn giữ log lỗi để debug kể cả khi tắt debug mode
      print('>>> [DIO ERROR]: ${e.message}');
      if (mounted) {
        final serverMsg = e.response?.data?['message'] ?? e.message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(serverMsg ?? 'Lỗi đăng nhập'))
        );
      }
    } catch (e) {
      print('>>> [UNKNOWN ERROR]: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra. Vui lòng thử lại.'))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Chào mừng trở lại!',
      subtitle: 'Đăng nhập để tiếp tục sử dụng Zenit',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoginForm(onSubmit: _handleLogin),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    // Hiển thị dòng này để biết đang delay do debug
                    Text("Đang xử lý (Debug Mode)...", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}