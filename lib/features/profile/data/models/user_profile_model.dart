import 'package:soulsync/features/profile/domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.email,
    super.firstName,
    super.lastName,
    required super.displayName,
    super.avatarUrl,
    super.bio,
    super.favoriteGenre,
    super.favoriteArtist,
    super.listeningGoal,
    super.timezone,
    super.country,
    super.isOnline,
    super.memberSince,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      displayName: json['displayName'] as String? ??
          json['display_name'] as String? ??
          json['first_name'] as String? ??
          'Partner',
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String? ?? '',
      favoriteGenre: json['favorite_genre'] as String? ?? 'Lo-Fi / R&B',
      favoriteArtist: json['favorite_artist'] as String? ?? '',
      listeningGoal: json['listening_goal'] as String? ?? '30 hrs / week',
      timezone: json['timezone'] as String? ?? 'UTC',
      country: json['country'] as String? ?? 'United States',
      isOnline: json['is_online'] as bool? ?? true,
      memberSince: json['date_joined'] != null
          ? DateTime.tryParse(json['date_joined'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'display_name': displayName,
      'bio': bio,
      'favorite_genre': favoriteGenre,
      'favorite_artist': favoriteArtist,
      'listening_goal': listeningGoal,
      'timezone': timezone,
      'country': country,
    };
  }
}
