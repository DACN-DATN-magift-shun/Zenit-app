# Authentication Service Documentation

## AuthService

`AuthService` là một singleton service để quản lý authentication state trong ứng dụng.

### Các phương thức chính:

#### 1. Kiểm tra trạng thái đăng nhập
```dart
final isLoggedIn = await AuthService().isAuthenticated();
```

#### 2. Lấy thông tin user
```dart
final userName = await AuthService().getUserDisplayName();
final userId = await AuthService().getUserId();
final userInfo = await AuthService().getUserInfo();
```

#### 3. Lưu thông tin đăng nhập
```dart
await AuthService().saveAuthData(
  accessToken: 'token_here',
  refreshToken: 'refresh_token_here',
  userId: 'user_id_here', // optional
);
```

#### 4. Đăng xuất
```dart
await AuthService().logout();
```

### Sử dụng trong widget:

#### Cách 1: Sử dụng trực tiếp
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final _authService = AuthService();
  bool _isAuthenticated = false;
  String _userName = 'Guest';

  @override
  void initState() {
    super.initState();
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final isAuth = await _authService.isAuthenticated();
    final userName = await _authService.getUserDisplayName();
    
    setState(() {
      _isAuthenticated = isAuth;
      _userName = userName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(_isAuthenticated 
      ? 'Hello, $_userName' 
      : 'Please login');
  }
}
```

#### Cách 2: Sử dụng AuthAwareWidget
```dart
import 'package:zenit/common/widgets/auth_aware_widget.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthAwareWidget(
      builder: (context, isAuthenticated, userName) {
        return Text(isAuthenticated 
          ? 'Hello, $userName' 
          : 'Please login');
      },
    );
  }
}
```

#### Cách 3: Sử dụng Extension method
```dart
import 'package:zenit/common/widgets/auth_aware_widget.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: context.isAuthenticated,
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Text('Logged in');
        }
        return Text('Not logged in');
      },
    );
  }
}
```

## Tích hợp với API

Khi backend cung cấp endpoint để lấy thông tin user, cập nhật phương thức `getUserInfo()` trong `auth_service.dart`:

```dart
Future<Map<String, dynamic>?> getUserInfo() async {
  try {
    final userId = await getUserId();
    if (userId == null) return null;

    final response = await _apiClient.dio.get(
      ApiEndpoints.accountById(userId),
    );
    return response.data['data'] ?? response.data;
  } catch (e) {
    print('Error fetching user info: $e');
    return null;
  }
}
```

## Best Practices

1. **Singleton Pattern**: AuthService sử dụng singleton, nên luôn gọi `AuthService()` thay vì tạo instance mới
2. **Loading State**: Luôn hiển thị loading indicator khi fetch auth state
3. **Error Handling**: Xử lý trường hợp token expired hoặc invalid
4. **Caching**: Cân nhắc cache user info để tránh gọi API nhiều lần
5. **Security**: Không log sensitive data như token trong production
