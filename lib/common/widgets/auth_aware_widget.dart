// import 'package:flutter/material.dart';
// import 'package:zenit/services/auth_service.dart';

// /// Widget helper để hiển thị nội dung khác nhau dựa trên trạng thái đăng nhập
// class AuthAwareWidget extends StatelessWidget {
//   final Widget Function(BuildContext context, bool isAuthenticated, String userName) builder;
  
//   const AuthAwareWidget({
//     super.key,
//     required this.builder,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _getAuthInfo(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
        
//         final data = snapshot.data ?? {'isAuth': false, 'userName': 'User'};
//         return builder(
//           context,
//           data['isAuth'] as bool,
//           data['userName'] as String,
//         );
//       },
//     );
//   }

//   Future<Map<String, dynamic>> _getAuthInfo() async {
//     final authService = AuthService();
//     final isAuth = await authService.isAuthenticated();
//     final userName = await authService.getUserDisplayName();
    
//     return {
//       'isAuth': isAuth,
//       'userName': userName,
//     };
//   }
// }

// /// Extension method để dễ dàng kiểm tra auth state trong widget
// extension AuthContextExtension on BuildContext {
//   Future<bool> get isAuthenticated => AuthService().isAuthenticated();
//   Future<String> get userName => AuthService().getUserDisplayName();
//   Future<String?> get userId => AuthService().getUserId();
// }
