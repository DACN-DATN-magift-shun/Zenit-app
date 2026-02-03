import 'package:flutter/material.dart';
import 'package:zenit/core/theme/app_theme.dart';

class PasswordFormField extends StatefulWidget {
  final String? hintText;
  final String? label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;

  const PasswordFormField({
    super.key,
    this.label,
    this.hintText = '••••••••',
    this.controller,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
        ],
  TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscureText,
      autovalidateMode: widget.autovalidateMode,
      style: TextStyle(color: Theme.of(context).extension<AppColorExtension>()!.primaryText),
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: Theme.of(context).extension<AppColorExtension>()!.primaryMain,
        hintStyle: TextStyle(color: Theme.of(context).extension<AppColorExtension>()!.primarySubtext),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).extension<AppColorExtension>()!.errorText),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Theme.of(context).extension<AppColorExtension>()!.primaryText,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    ),
      ],
    );
  }
}
