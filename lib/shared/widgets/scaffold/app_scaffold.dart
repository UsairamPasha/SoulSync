import 'package:flutter/material.dart';
import 'package:soulsync/shared/widgets/loading/app_full_screen_loader.dart';

/// Reusable Page Scaffold wrapper for SoulSync supporting AppBar, Body, FAB, BottomNav, and Loading Overlay.
class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool isLoading;
  final String? loadingMessage;
  final bool resizeToAvoidBottomInset;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.isLoading = false,
    this.loadingMessage,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppFullScreenLoader(
      isLoading: isLoading,
      message: loadingMessage,
      child: Scaffold(
        appBar: appBar,
        body: SafeArea(child: body),
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      ),
    );
  }
}
