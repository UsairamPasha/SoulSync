import 'package:soulsync/features/home/data/models/dashboard_data_model.dart';

abstract class DashboardRepository {
  Future<DashboardDataModel> getDashboardData();
}

class MockDashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<DashboardDataModel> getDashboardData() async {
    // Artificial 300ms delay simulating local cache / fast sync
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return const DashboardDataModel(
      coupleStatus: CoupleStatusModel(
        partnerName: 'My Soulmate',
        partnerAvatarUrl:
            'https://api.dicebear.com/7.x/avataaars/svg?seed=Wife',
        isOnline: true,
        roomName: 'Usairam & Partner Sync Room',
        isSyncing: true,
      ),
      currentSong: CurrentSongModel(
        title: 'Soulmate Serenade',
        artist: 'The Lovers',
        albumArtUrl: 'https://picsum.photos/300/300?random=1',
        duration: Duration(minutes: 3, seconds: 45),
        currentPosition: Duration(minutes: 1, seconds: 20),
        isPlaying: true,
      ),
      recentActivities: [],
      stats: UserStatsModel(
        totalSongs: 0,
        totalPlaylists: 0,
        totalFavorites: 0,
        listeningHours: 0.0,
      ),
    );
  }
}
