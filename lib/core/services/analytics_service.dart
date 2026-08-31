import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/logger/app_logger.dart';

/// Analytics tracking service interface.
abstract class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters});
  Future<void> setUserId(String userId);
}

class AnalyticsServiceImpl implements AnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    AppLogger.info('Analytics Event: $name | params: $parameters');
  }

  @override
  Future<void> setUserId(String userId) async {
    AppLogger.info('Analytics Set User ID: $userId');
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsServiceImpl();
});
