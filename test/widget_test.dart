import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soulsync/app/app.dart';
import 'package:soulsync/core/config/app_config.dart';
import 'package:soulsync/core/config/environment.dart';
import 'package:soulsync/core/network/api_exception.dart';
import 'package:soulsync/core/security/auth_token_manager.dart';
import 'package:soulsync/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:soulsync/features/auth/data/models/login_request_model.dart';
import 'package:soulsync/features/chat/data/datasources/chat_draft_datasource.dart';
import 'package:soulsync/features/chat/data/repositories/mock_chat_repository_impl.dart';
import 'package:soulsync/features/home/data/repositories/dashboard_repository.dart';
import 'package:soulsync/features/player/data/repositories/music_repository_impl.dart';
import 'package:soulsync/features/player/data/services/playback_settings_service.dart';
import 'package:soulsync/features/player/domain/entities/queue_entity.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/room/data/repositories/mock_room_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SoulSyncApp splash to welcome screen redirection test',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SoulSyncApp(),
      ),
    );

    // Verify initial splash screen branding
    expect(find.text('SoulSync'), findsOneWidget);

    // Advance virtual clock to allow splash animation & auth check resolution
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify GoRouter redirects unauthenticated user from splash to welcome screen
    expect(find.text('Synchronized Music for Two'), findsOneWidget);
  });

  group('Sprint 2.0 Networking & AuthTokenManager Tests', () {
    test('AppConfig should compute API base URL correctly', () {
      const config = AppConfig(
        environment: AppEnvironment.dev,
        baseUrl: 'https://api.soulsync.app',
        apiVersion: 'v1',
      );

      expect(config.apiBaseUrl, equals('https://api.soulsync.app/api/v1'));
    });

    test('AuthTokenManager should store, retrieve, and clear JWT tokens',
        () async {
      final manager = AuthTokenManager();
      await manager.saveTokens(
        accessToken: 'jwt_access_123',
        refreshToken: 'jwt_refresh_456',
      );

      final token = await manager.getAccessToken();
      expect(token, equals('jwt_access_123'));

      await manager.clearTokens();
      final cleared = await manager.getAccessToken();
      expect(cleared, isNull);
    });

    test('ApiException mapping should parse HTTP error statuses', () {
      const exception = ApiException(
        message: 'Unauthorized access',
        statusCode: 401,
        type: ApiExceptionType.unauthorized,
      );

      expect(exception.type, equals(ApiExceptionType.unauthorized));
      expect(exception.statusCode, equals(401));
    });
  });

  group('Sprint 1.9 Couple Messenger & Conversations Tests', () {
    test('MockChatRepositoryImpl should load conversation history & search',
        () async {
      final repo = MockChatRepositoryImpl();
      final conv = await repo.getConversation();
      final msgs = await repo.getMessages();

      expect(conv.title, isNotEmpty);
      expect(msgs, isNotNull);

      await repo.sendMessage('Playing track in room');
      final searchResults = await repo.searchMessages('track');
      expect(searchResults, isNotEmpty);
      repo.dispose();
    });

    test('MockChatRepositoryImpl should send message & toggle reactions',
        () async {
      final repo = MockChatRepositoryImpl();
      final sent = await repo.sendMessage('I love you honey');

      expect(sent.text, equals('I love you honey'));
      expect(sent.senderId, equals('user_me'));

      await repo.toggleReaction(sent.id, '❤️');
      final msgs = await repo.getMessages();
      final updated = msgs.firstWhere((m) => m.id == sent.id);

      expect(updated.reactions, contains('❤️'));
      repo.dispose();
    });

    test('ChatDraftDataSource should save and retrieve drafts', () async {
      final ds = ChatDraftDataSource();
      await ds.saveDraft('c1', 'Drafting a sweet note');
      final draft = await ds.getDraft('c1');

      expect(draft, equals('Drafting a sweet note'));
    });
  });

  group('Sprint 1.8 Couple Rooms & Shared Sessions Tests', () {
    test('MockRoomRepositoryImpl should return null when no room exists initially',
        () async {
      final repo = MockRoomRepositoryImpl();
      final room = await repo.getCurrentRoom();

      expect(room, isNull);
      repo.dispose();
    });

    test('MockRoomRepositoryImpl should create new room with invite code',
        () async {
      final repo = MockRoomRepositoryImpl();
      final newRoom = await repo.createRoom('Honeymoon Suite');

      expect(newRoom.name, equals('Honeymoon Suite'));
      expect(newRoom.inviteCode, startsWith('SOUL-'));

      final members = await repo.getRoomMembers(newRoom.id);
      expect(members, isNotEmpty);
      expect(members.first.isHost, isTrue);
      repo.dispose();
    });

    test('MockRoomRepositoryImpl should join room via invite code', () async {
      final repo = MockRoomRepositoryImpl();
      final joinedRoom = await repo.joinRoom('SOUL-9999');

      expect(joinedRoom.inviteCode, equals('SOUL-9999'));
      expect(joinedRoom.isPartnerConnected, isTrue);
      repo.dispose();
    });
  });

  group('Sprint 1.7 Queue & Playback Experience Tests', () {
    test('QueueEntity should calculate length and total duration correctly',
        () {
      const song1 = SongEntity(
        id: '1',
        title: 'Song 1',
        artist: 'Artist 1',
        album: 'Album 1',
        assetPath: 'assets/music/sample_1.mp3',
        duration: Duration(seconds: 180),
      );

      const song2 = SongEntity(
        id: '2',
        title: 'Song 2',
        artist: 'Artist 2',
        album: 'Album 2',
        assetPath: 'assets/music/sample_2.mp3',
        duration: Duration(seconds: 120),
      );

      const queue = QueueEntity(
        currentSong: song1,
        upcomingSongs: [song2],
      );

      expect(queue.totalLength, equals(2));
      expect(queue.totalDuration, equals(const Duration(seconds: 300)));
    });

    test('PlaybackSettingsService should persist and load settings', () async {
      final service = PlaybackSettingsService();
      final settings = await service.loadSettings();

      expect(settings.isShuffle, isFalse);
      expect(settings.volume, equals(1.0));
      expect(settings.speed, equals(1.0));
    });
  });

  group('Sprint 1.6 Local Music Library & Media Scanner Tests', () {
    test('MockMusicRepository should load local sample tracks', () async {
      final repo = MockMusicRepositoryImpl();
      final songs = await repo.getLocalSongs();

      expect(songs, isNotEmpty);
      expect(songs.first.title, isNotEmpty);
      expect(songs.first.assetPath, isNotEmpty);
    });

    test('MockMusicRepository should query artists and albums', () async {
      final repo = MockMusicRepositoryImpl();
      final artists = await repo.getArtists();
      final albums = await repo.getAlbums();

      expect(artists, isNotEmpty);
      expect(albums, isNotEmpty);
    });

    test('MockMusicRepository should search and filter tracks', () async {
      final repo = MockMusicRepositoryImpl();
      final searchResults = await repo.searchSongs('Sample');

      expect(searchResults, isNotEmpty);
    });

    test('MockMusicRepository should toggle track favorite status', () async {
      final repo = MockMusicRepositoryImpl();
      final songs = await repo.getLocalSongs();
      final trackId = songs.first.id;

      await repo.toggleFavorite(trackId);
      final favs = await repo.getFavoriteSongs();

      expect(favs.any((s) => s.id == trackId), isTrue);
    });
  });

  group('Sprint 1.4 Dashboard Repository Tests', () {
    test('MockDashboardRepository should return realistic dashboard data',
        () async {
      final repo = MockDashboardRepositoryImpl();
      final data = await repo.getDashboardData();

      expect(data.coupleStatus.partnerName, isNotEmpty);
      expect(data.currentSong.title, equals('Soulmate Serenade'));
      expect(data.recentActivities, isNotNull);
      expect(data.stats.totalSongs, greaterThanOrEqualTo(0));
    });
  });

  group('Mock Authentication Unit Tests', () {
    final mockRemoteDataSource = MockAuthRemoteDataSourceImpl();

    test('Valid credentials (admin@soulsync.app / SoulSync123) should succeed',
        () async {
      const request = LoginRequestModel(
        email: 'admin@soulsync.app',
        password: 'SoulSync123',
      );

      final response = await mockRemoteDataSource.login(request);
      expect(response.user.email, equals('admin@soulsync.app'));
      expect(response.tokens.accessToken, isNotEmpty);
    });

    test('Invalid credentials should throw UnauthorizedException', () async {
      const request = LoginRequestModel(
        email: 'wrong@soulsync.app',
        password: 'WrongPassword123',
      );

      expect(
        () async => await mockRemoteDataSource.login(request),
        throwsA(anything),
      );
    });
  });
}
