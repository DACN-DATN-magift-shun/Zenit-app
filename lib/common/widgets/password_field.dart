import 'package:flutter/material.dart';
import 'package:zenit/common/theme/app_colors.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool filled;
  final Color? fillColor;

  const PasswordField({
    Key? key,
    this.controller,
    this.hintText = '••••••••',
    this.filled = true,
    this.fillColor,
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}
class _PasswordFieldState extends State<PasswordField>{
  bool _obscureText = true; 
  @override
  Widget build(BuildContext context){
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: widget.filled,
        fillColor: widget.fillColor ?? AppColors.light.primaryMain,
        hintStyle: TextStyle(color: AppColors.light.secondaryHover, fontWeight: FontWeight.normal),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.light.primaryText),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      ),
      style: TextStyle(color: AppColors.light.primaryText, fontWeight: FontWeight.bold),
    );
  }
}