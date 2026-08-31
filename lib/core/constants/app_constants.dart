/// Centralized application constants for SoulSync.
abstract class AppConstants {
  static const String appName = 'SoulSync';
  static const String appVersion = '1.0.0';

  // Animation & Transition Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 250);
  static const Duration snackBarDuration = Duration(seconds: 4);

  // UI Spacing & Layout Constraints
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double cardElevation = 2.0;
}
