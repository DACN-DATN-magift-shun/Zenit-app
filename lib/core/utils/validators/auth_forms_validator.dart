class AuthFormsValidator {
  // Email validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  // username validator
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên đăng nhập';
    }
    if (value.length < 3 || value.length > 20) {
      return 'Tên đăng nhập phải từ 3 đến 20 ký tự';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Tên đăng nhập chỉ được chứa chữ cái, số và dấu gạch dưới';
    }
    return null;
  }

  // Password validator
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length <= 8) {
      return 'Mật khẩu phải dài hơn 8 ký tự';
    }
    final hasNumber = RegExp(r'\d').hasMatch(value);
    final hasSpecial = RegExp(
      r'[!@#\$%\^&\*\(\)\+\=\{\}\[\]:;"\\<>,\.\?\/\\|~`_    -]',
    ).hasMatch(value);
    if (!hasNumber) {
      return 'Mật khẩu phải chứa ít nhất một chữ số';
    }
    if (!hasSpecial) {
      return 'Mật khẩu phải chứa ít nhất một ký tự đặc biệt';
    }
    return null;
  }

  // Confirm password validator
  static String? Function(String?) confirmPassword(String Function() getPassword) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Vui lòng xác nhận mật khẩu';
      }
      if (value != getPassword()) {
        return 'Mật khẩu không khớp';
      }
      return null;
    };
  }

  // phone validator
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Số điện thoại không hợp lệ';
    }
    if (value.length != 10) {
      return 'Số điện thoại phải có 10 chữ số';
    }
    return null;
  }

  // address validator
  static String? address(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập địa chỉ';
    }
    if (value.length < 5) {
      return 'Địa chỉ quá ngắn';
    }
    return null;
  }

  // Required field validator
  static String? required(String? value, {String fieldName = 'Trường này'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  // Combine multiple validators
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
