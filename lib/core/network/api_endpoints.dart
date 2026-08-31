/// Centralized API endpoint paths for Node.js backend integration.
abstract class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Room & Synchronization
  static const String createRoom = '/room/create';
  static const String joinRoom = '/room/join';
  static const String roomState = '/room/state';

  // Music & Streaming
  static const String searchTracks = '/music/search';
  static const String trackDetails = '/music/track';
  static const String streamTrack = '/music/stream';

  // Playlists & Favorites
  static const String playlists = '/playlists';
  static const String favorites = '/favorites';
}
