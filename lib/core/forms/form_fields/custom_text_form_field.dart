import 'package:flutter/material.dart';
import 'package:zenit/core/theme/app_theme.dart';

class CustomTextFormField extends StatelessWidget{
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool filled;
  final Color? fillColor;
  final AutovalidateMode autovalidateMode;

  const CustomTextFormField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.filled = true,
    this.fillColor,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      autovalidateMode: autovalidateMode,
      style: TextStyle(color: Theme.of(context).extension<AppColorExtension>()!.primaryText),
      decoration: InputDecoration(
        hintText: hintText,
        filled: filled,
        hintStyle: TextStyle(color: Theme.of(context).extension<AppColorExtension>()!.primarySubtext),
        fillColor: fillColor ?? Theme.of(context).extension<AppColorExtension>()!.primaryMain,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      ),
    )
      ],
      );
  }
}