// import 'package:flutter/material.dart';
// import 'package:zenit/services/auth_service.dart';
// import 'package:zenit/common/utils/services/navigation_service.dart';

// /// Widget button để logout - có thể tái sử dụng ở nhiều nơi
// class LogoutButton extends StatelessWidget {
//   final String? text;
//   final IconData? icon;
//   final VoidCallback? onLogoutSuccess;
  
//   const LogoutButton({
//     super.key,
//     this.text,
//     this.icon,
//     this.onLogoutSuccess,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton.icon(
//       onPressed: () => _handleLogout(context),
//       icon: Icon(icon ?? Icons.logout),
//       label: Text(text ?? 'Đăng xuất'),
//     );
//   }

//   Future<void> _handleLogout(BuildContext context) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Xác nhận đăng xuất'),
//         content: const Text('Bạn có chắc muốn đăng xuất không?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Hủy'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text('Đăng xuất'),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true && context.mounted) {
//       try {
//         await AuthService().logout();
        
//         if (context.mounted) {
//           NavigationService.instance.pushAndRemoveUntil(
//             '/login',
//             arguments: {'snackMessage': 'Đã đăng xuất thành công'},
//           );
//           onLogoutSuccess?.call();
//         }
//       } catch (e) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Lỗi khi đăng xuất: $e')),
//           );
//         }
//       }
//     }
//   }
// }
