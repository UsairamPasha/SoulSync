/// Centralized Asset Paths for SoulSync.
abstract class AppAssets {
  // Directory Roots
  static const String imagesDir = 'assets/images/';
  static const String iconsDir = 'assets/icons/';
  static const String musicDir = 'assets/music/';
  static const String animationsDir = 'assets/animations/';
  static const String fontsDir = 'assets/fonts/';

  // Image Assets
  static const String logo = '${imagesDir}logo.png';
  static const String defaultAvatar = '${imagesDir}default_avatar.png';
  static const String defaultAlbumArt = '${imagesDir}default_album_art.png';

  // Icon Assets
  static const String iconSync = '${iconsDir}sync.svg';
  static const String iconMusic = '${iconsDir}music.svg';

  // Animation Assets
  static const String animLoading = '${animationsDir}loading.json';
  static const String animSyncing = '${animationsDir}syncing.json';

  // Placeholder Audio Assets
  static const String sampleAudio = '${musicDir}sample.mp3';
}
