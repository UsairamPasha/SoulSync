import 'package:flutter/material.dart';
import 'package:soulsync/shared/widgets/buttons/app_primary_button.dart';

/// Legacy alias for AppPrimaryButton maintaining backwards compatibility.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppPrimaryButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
    );
  }
}
