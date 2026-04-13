import 'package:flutter/material.dart';
import 'package:zenit/core/theme/app_theme.dart';

class CustomTextFormField extends StatelessWidget {
  final String? label;
  final Widget? labelTrailing;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool filled;
  final Color? fillColor;
  final AutovalidateMode autovalidateMode;
  final bool enabled;
  final int maxLines;

  const CustomTextFormField({
    super.key,
    this.label,
    this.labelTrailing,
    this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.filled = true,
    this.fillColor,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final theme = Theme.of(context);
    final textColor = (!enabled && !filled)
        ? theme.colorScheme.onSurface
        : appColors.neutralTextPrimary;
    final effectiveFillColor =
        fillColor ??
        theme.inputDecorationTheme.fillColor ??
        appColors.primaryMain;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  label!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (labelTrailing != null) ...[
                const SizedBox(width: 8),
                labelTrailing!,
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          autovalidateMode: autovalidateMode,
          enabled: enabled,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hintText,
            filled: filled,
            hintStyle: TextStyle(color: appColors.primarySubtext),
            fillColor: effectiveFillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 14.0,
              horizontal: 16.0,
            ),
          ),
        ),
      ],
    );
  }
}
