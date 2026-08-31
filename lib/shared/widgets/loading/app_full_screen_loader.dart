import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:soulsync/shared/widgets/loading/app_circular_loader.dart';

/// Reusable Modal Full-Screen Loading Overlay with backdrop blur for SoulSync.
class AppFullScreenLoader extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final Widget child;

  const AppFullScreenLoader({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: AppCircularLoader(message: message),
              ),
            ),
          ),
      ],
    );
  }
}
