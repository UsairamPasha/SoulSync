import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Network connectivity check interface.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // Placeholder implementation ready for connectivity_plus plugin
    return true;
  }
}

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});
