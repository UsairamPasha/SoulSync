import 'package:soulsync/features/profile/domain/entities/invitation_entity.dart';

class InvitationModel extends InvitationEntity {
  const InvitationModel({
    required super.id,
    required super.invitationCode,
    required super.status,
    required super.expiresAt,
    required super.createdAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'] as String? ?? '',
      invitationCode: json['invitation_code'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
