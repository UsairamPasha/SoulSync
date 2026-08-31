import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:soulsync/shared/widgets/loading/app_circular_loader.dart';

import 'package:soulsync/core/widgets/server_url_dialog.dart';

/// Professional Animated Splash Screen checking Auth State on Startup.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Artificial 1.5s delay to allow splash animation to play smoothly
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      await ref.read(authNotifierProvider.notifier).checkAuthStatus();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 48,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.settings_rounded, color: Colors.white60, size: 28),
              tooltip: 'Server Settings',
              onPressed: () => ServerUrlDialog.show(context),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.queue_music_rounded,
                      size: 96,
                      color: context.colorScheme.primary,
                    ),
                    AppSpacing.vGapMD,
                    Text(
                      'SoulSync',
                      style: context.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.primary,
                      ),
                    ),
                    AppSpacing.vGapXS,
                    Text(
                      'Synchronized Music for Two',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.vGapXXL,
                    const AppCircularLoader(size: 28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
