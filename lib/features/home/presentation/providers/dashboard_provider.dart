import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/features/home/data/models/dashboard_data_model.dart';
import 'package:soulsync/features/home/data/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return MockDashboardRepositoryImpl();
});

final dashboardDataProvider = FutureProvider<DashboardDataModel>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getDashboardData();
});
