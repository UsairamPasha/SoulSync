import 'package:soulsync/features/profile/domain/entities/user_profile_entity.dart';

class CoupleEntity {
  final String id;
  final UserProfileEntity? partner;
  final String status;
  final DateTime? anniversaryDate;
  final DateTime createdAt;

  const CoupleEntity({
    required this.id,
    this.partner,
    required this.status,
    this.anniversaryDate,
    required this.createdAt,
  });

  bool get isConnected => status.toLowerCase() == 'accepted';
}
