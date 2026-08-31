import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SafeNavigation {
  static DateTime _lastNavTime = DateTime.now().subtract(const Duration(seconds: 1));

  static void safeGo(BuildContext context, String location, {Object? extra}) {
    final now = DateTime.now();
    if (now.difference(_lastNavTime).inMilliseconds < 400) return;
    _lastNavTime = now;
    context.go(location, extra: extra);
  }

  static void safePush(BuildContext context, String location, {Object? extra}) {
    final now = DateTime.now();
    if (now.difference(_lastNavTime).inMilliseconds < 400) return;
    _lastNavTime = now;

    // Shell branch routes switch tab via go() instead of pushing duplicates onto shell stack
    final isShellTab = location == '/home' ||
        location == '/player' ||
        location == '/playlist' ||
        location == '/chat' ||
        location == '/profile';

    if (isShellTab) {
      context.go(location, extra: extra);
    } else {
      context.push(location, extra: extra);
    }
  }

  static bool _isDialogShowing = false;

  static Future<T?> safeShowDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) async {
    if (_isDialogShowing) return null;
    _isDialogShowing = true;
    try {
      final result = await showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: builder,
      );
      return result;
    } finally {
      _isDialogShowing = false;
    }
  }

  static Future<T?> safeShowModalBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = false,
  }) async {
    if (_isDialogShowing) return null;
    _isDialogShowing = true;
    try {
      final result = await showModalBottomSheet<T>(
        context: context,
        isScrollControlled: isScrollControlled,
        builder: builder,
      );
      return result;
    } finally {
      _isDialogShowing = false;
    }
  }
}

