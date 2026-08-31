import 'package:soulsync/features/profile/data/models/user_profile_model.dart';
import 'package:soulsync/features/profile/domain/entities/couple_entity.dart';

class CoupleModel extends CoupleEntity {
  const CoupleModel({
    required super.id,
    super.partner,
    required super.status,
    super.anniversaryDate,
    required super.createdAt,
  });

  factory CoupleModel.fromJson(Map<String, dynamic> json) {
    UserProfileModel? partnerModel;
    if (json['partner'] != null && json['partner'] is Map<String, dynamic>) {
      partnerModel =
          UserProfileModel.fromJson(json['partner'] as Map<String, dynamic>);
    }

    return CoupleModel(
      id: json['id'] as String? ?? '',
      partner: partnerModel,
      status: json['relationship_status'] as String? ?? 'accepted',
      anniversaryDate: json['anniversary_date'] != null
          ? DateTime.tryParse(json['anniversary_date'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
