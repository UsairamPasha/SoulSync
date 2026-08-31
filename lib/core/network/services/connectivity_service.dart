import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  final StreamController<bool> _isOnlineController =
      StreamController<bool>.broadcast();
  bool _isOnline = true;
  Timer? _timer;

  ConnectivityService() {
    _init();
  }

  bool get isOnline => _isOnline;
  Stream<bool> get onConnectivityChanged => _isOnlineController.stream;

  void _init() {
    _isOnlineController.add(true);
  }

  void setOnlineState(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      _isOnlineController.add(online);
    }
  }

  void dispose() {
    _timer?.cancel();
    _isOnlineController.close();
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

final isOnlineStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});
