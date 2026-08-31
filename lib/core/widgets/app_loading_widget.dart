import 'package:flutter/material.dart';
import 'package:soulsync/shared/widgets/loading/app_circular_loader.dart';

/// Legacy alias for AppCircularLoader maintaining backwards compatibility.
class AppLoadingWidget extends StatelessWidget {
  final String? message;

  const AppLoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppCircularLoader(message: message);
  }
}
