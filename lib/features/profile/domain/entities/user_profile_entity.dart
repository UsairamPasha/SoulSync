class UserProfileEntity {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
  final String? avatarUrl;
  final String bio;
  final String favoriteGenre;
  final String favoriteArtist;
  final String listeningGoal;
  final String timezone;
  final String country;
  final bool isOnline;
  final DateTime? memberSince;

  const UserProfileEntity({
    required this.id,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    required this.displayName,
    this.avatarUrl,
    this.bio = '',
    this.favoriteGenre = 'Lo-Fi / R&B',
    this.favoriteArtist = '',
    this.listeningGoal = '30 hrs / week',
    this.timezone = 'UTC',
    this.country = 'United States',
    this.isOnline = true,
    this.memberSince,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : displayName;
  }

  UserProfileEntity copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? favoriteGenre,
    String? favoriteArtist,
    String? listeningGoal,
    String? timezone,
    String? country,
    bool? isOnline,
    DateTime? memberSince,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      favoriteGenre: favoriteGenre ?? this.favoriteGenre,
      favoriteArtist: favoriteArtist ?? this.favoriteArtist,
      listeningGoal: listeningGoal ?? this.listeningGoal,
      timezone: timezone ?? this.timezone,
      country: country ?? this.country,
      isOnline: isOnline ?? this.isOnline,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}
