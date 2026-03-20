import 'package:flutter/material.dart';

class AuthErrorMessage {
  static String resolve({
    required BuildContext context,
    required dynamic responseData,
    required String fallback,
  }) {
    final isVi = Localizations.localeOf(context).languageCode == 'vi';

    String? details;
    String? message;
    if (responseData is Map<String, dynamic>) {
      details = responseData['details']?.toString();
      message = responseData['message']?.toString();
    } else if (responseData is Map) {
      details = responseData['details']?.toString();
      message = responseData['message']?.toString();
    }

    final code = details?.trim().toUpperCase();
    if (code != null && code.isNotEmpty) {
      final mapped = _mapCode(code, isVi);
      if (mapped != null) return mapped;
    }

    if (message != null &&
        message.isNotEmpty &&
        message.toLowerCase() != 'internal server error') {
      return message;
    }

    if (responseData is String && responseData.isNotEmpty) {
      return responseData;
    }

    return fallback;
  }

  static String? _mapCode(String code, bool isVi) {
    switch (code) {
      case 'ACCOUNT_NOT_FOUND':
        return isVi
            ? 'Không tìm thấy tài khoản với email này.'
            : 'No account found with this email.';
      case 'WRONG_PASSWORD':
        return isVi ? 'Mật khẩu không đúng.' : 'Incorrect password.';
      case 'EMAIL_ALREADY_EXISTS':
        return isVi
            ? 'Email này đã được đăng ký.'
            : 'This email is already registered.';
      case 'USERNAME_ALREADY_EXISTS':
        return isVi
            ? 'Tên người dùng đã tồn tại.'
            : 'This username already exists.';
      case 'OTP_EXPIRED':
        return isVi
            ? 'OTP đã hết hạn. Vui lòng nhập lại email để yêu cầu mã mới.'
            : 'OTP has expired. Please request a new code.';
      case 'INVALID_OTP':
        return isVi ? 'OTP không hợp lệ.' : 'Invalid OTP.';
      case 'RESET_TOKEN_INVALID':
        return isVi
            ? 'Liên kết đặt lại mật khẩu không hợp lệ.'
            : 'Invalid reset token.';
      case 'RESET_TOKEN_EXPIRED':
        return isVi
            ? 'Liên kết đặt lại mật khẩu đã hết hạn.'
            : 'Reset token has expired.';
      default:
        return null;
    }
  }
}
