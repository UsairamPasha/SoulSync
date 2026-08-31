import 'package:soulsync/core/errors/failures.dart';
import 'package:soulsync/features/profile/domain/entities/couple_entity.dart';
import 'package:soulsync/features/profile/domain/entities/invitation_entity.dart';
import 'package:soulsync/features/profile/domain/entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<({Failure? failure, UserProfileEntity? profile})> getProfile();
  Future<({Failure? failure, UserProfileEntity? profile})> updateProfile(
      UserProfileEntity profile);
  Future<({Failure? failure, UserProfileEntity? profile})> uploadAvatar(
      String filePath);

  Future<({Failure? failure, InvitationEntity? invitation})> createInvite();
  Future<({Failure? failure, CoupleEntity? relationship})> acceptInvite(
      String code);
  Future<Failure?> rejectInvite(String code);
  Future<
      ({
        Failure? failure,
        CoupleEntity? relationship,
        InvitationEntity? pendingInvitation
      })> getRelationship();
  Future<Failure?> removeRelationship();
  Future<({Failure? failure, UserProfileEntity? partner})> getPartnerProfile();
}
