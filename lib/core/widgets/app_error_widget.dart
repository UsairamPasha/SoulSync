import 'package:flutter/material.dart';
import 'package:soulsync/shared/widgets/states/app_error_state.dart';

/// Legacy alias for AppErrorState maintaining backwards compatibility.
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorState.generic(
      message: message,
      onRetry: onRetry,
    );
  }
}
