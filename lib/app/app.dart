import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/app/router.dart';
import 'package:soulsync/app/theme.dart';
import 'package:soulsync/core/constants/app_constants.dart';
import 'package:soulsync/core/lifecycle/app_lifecycle_observer.dart';
import 'package:soulsync/shared/providers/shared_providers.dart';

/// Root Application Widget for SoulSync.
class SoulSyncApp extends ConsumerWidget {
  const SoulSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Instantiate/watch AppLifecycleObserver for global background recovery
    ref.watch(appLifecycleObserverProvider);

    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
