import 'package:flutter/material.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/widgets/button.dart';
import 'package:zenit/core/forms/form_fields/custom_text_form_field.dart';
import 'package:zenit/core/services/auth_service.dart';

// Code này tao dùng AI để beautify lại nka, chớ k có vibe coding:v

class ProfileForm extends StatefulWidget {
  final void Function(
    String phone,
    String address,
  ) onSubmit;

  const ProfileForm({super.key, required this.onSubmit});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  
  // 1. Khai báo Controller - Mấy thằng đệ quản lý ô nhập liệu
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final AuthService _authService = AuthService();
  
  // Biến check xem đang load hay không để hiện vòng xoay cho chuyên nghiệp
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    // dispose các controller khi widget bị hủy
    _emailController.dispose();
    _usernameController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // 2. Hàm load dữ liệu và gán thẳng vào Controller
  Future<void> _loadUserInfo() async {
    final isAuth = await _authService.isAuthenticated();
    if (isAuth) {
      final userInfo = await _authService.getUserInfo();
      if (userInfo != null && userInfo.statusCode == 200) {
        final data = userInfo.data;
               
        setState(() {
          _emailController.text = data['email'] ?? '--';
          _usernameController.text = data['username'] ?? '--';
          _dateOfBirthController.text = data['dateOfBirth'] ?? '--';
          _phoneController.text = data['phone'] ?? '';
          _addressController.text = data['address'] ?? '';
          _isLoading = false; 
        });
      }
    } else {
       setState(() => _isLoading = false);
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Gửi giá trị từ controller đi
      widget.onSubmit(
        _phoneController.text.trim(),
        _addressController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Nếu chưa load xong thì hiện vòng xoay, khỏi hiện form lỗi
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Avatar Section ---
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/user.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 15, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Form Fields Section ---
            // 3. Gắn Controller vào từng Widget
            CustomTextFormField(
              label: l10n.email,
              controller: _emailController,
              filled: false,
              enabled: false,
            ),
            CustomTextFormField(
              label: l10n.username,
              controller: _usernameController,
              filled: false,
              enabled: false,
            ),
            // CustomTextFormField(
            //   label: 'Date of Birth',
            //   controller: _dateOfBirthController,
            // ),
            CustomTextFormField(
              label: l10n.phone,
              controller: _phoneController,
            ),
            CustomTextFormField(
              label: l10n.address,
              controller: _addressController,
            ),
            
            const SizedBox(height: 20),
            
            // --- Submit Button ---
            AppButton(
              text: l10n.saveChanges,
              onPressed: _handleSubmit,
            ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}