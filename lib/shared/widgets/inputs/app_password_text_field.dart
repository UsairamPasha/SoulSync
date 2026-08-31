import 'package:flutter/material.dart';
import 'package:soulsync/core/utils/validators.dart';
import 'package:soulsync/shared/widgets/inputs/app_text_field.dart';

/// Reusable Password Input Field component with toggle visibility for SoulSync.
class AppPasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const AppPasswordTextField({
    super.key,
    this.controller,
    this.labelText = 'Password',
    this.hintText = 'enter your password',
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<AppPasswordTextField> createState() => _AppPasswordTextFieldState();
}

class _AppPasswordTextFieldState extends State<AppPasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      hintText: widget.hintText,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      validator: Validators.validatePassword,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
    );
  }
}
