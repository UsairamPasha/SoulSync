import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/theme_extensions.dart';

/// Extension on [BuildContext] to simplify access to Theme, ColorScheme, MediaQuery, and Custom Tokens.
extension ContextExtensions on BuildContext {
  // Theme extensions
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Custom ThemeExtension
  SoulSyncCustomColors get customColors =>
      Theme.of(this).extension<SoulSyncCustomColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? SoulSyncCustomColors.dark
          : SoulSyncCustomColors.light);

  // MediaQuery extensions
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;

  // Orientation
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  // SnackBar helper
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
      ),
    );
  }
}
