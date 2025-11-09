import 'package:flutter/material.dart';
import 'package:zenit/common/theme/app_colors.dart';
import 'package:zenit/common/theme/app_sizes.dart';
import 'package:zenit/common/theme/app_theme.dart';

class InputField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool filled;
  final Color? fillColor;
  final TextInputType? keyboardType;

  const InputField({
    Key? key,
    this.controller,
    this.hintText,
    this.filled = true,
    this.fillColor,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        filled: filled,
        fillColor: fillColor ?? Theme.of(context).extension<AppColorExtension>()!.primaryMain,
        hintStyle: TextStyle(color: Theme.of(context).extension<AppColorExtension>()!.secondaryHover, fontWeight: FontWeight.normal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      ),
      style: TextStyle(
        color: AppColors.light.primaryText,
        fontWeight: FontWeight.bold,
      ),
    );
  }



}