import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/network/services/connectivity_service.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineStreamProvider).value ?? true;

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 250),
      crossFadeState: isOnline ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: const SizedBox.shrink(),
      secondChild: Container(
        width: double.infinity,
        color: Colors.red.shade700,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'No internet connection. Trying to reconnect...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
