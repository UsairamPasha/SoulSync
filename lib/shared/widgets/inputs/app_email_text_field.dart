import 'package:flutter/material.dart';
import 'package:soulsync/core/utils/validators.dart';
import 'package:soulsync/shared/widgets/inputs/app_text_field.dart';

/// Reusable Email Input Field component for SoulSync.
class AppEmailTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const AppEmailTextField({
    super.key,
    this.controller,
    this.labelText = 'Email Address',
    this.hintText = 'enter your email',
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.email_outlined, size: 20),
      validator: Validators.validateEmail,
      onChanged: onChanged,
      enabled: enabled,
    );
  }
}
