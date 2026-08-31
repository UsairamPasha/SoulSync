import 'package:dio/dio.dart';
import 'package:soulsync/core/errors/failures.dart';
import 'package:soulsync/core/network/dio_client.dart';
import 'package:soulsync/features/profile/data/models/couple_model.dart';
import 'package:soulsync/features/profile/data/models/invitation_model.dart';
import 'package:soulsync/features/profile/data/models/user_profile_model.dart';
import 'package:soulsync/features/profile/domain/entities/couple_entity.dart';
import 'package:soulsync/features/profile/domain/entities/invitation_entity.dart';
import 'package:soulsync/features/profile/domain/entities/user_profile_entity.dart';
import 'package:soulsync/features/profile/domain/repositories/profile_repository.dart';

class ProfileApiRepositoryImpl implements ProfileRepository {
  final DioClient _dioClient;

  ProfileApiRepositoryImpl(this._dioClient);

  @override
  Future<({Failure? failure, UserProfileEntity? profile})> getProfile() async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>('/profile/');
      final payload = response.data;
      if (payload != null &&
          payload['success'] == true &&
          payload['data'] != null) {
        final profileModel =
            UserProfileModel.fromJson(payload['data'] as Map<String, dynamic>);
        return (failure: null, profile: profileModel);
      }
      return (
        failure: const ServerFailure(message: 'Failed to retrieve profile.'),
        profile: null
      );
    } on DioException catch (e) {
      return (
        failure: NetworkFailure(message: 'Profile fetch failed: ${e.message}'),
        profile: null
      );
    } catch (e) {
      return (
        failure: UnknownFailure(message: 'Profile fetch error: $e'),
        profile: null
      );
    }
  }

  @override
  Future<({Failure? failure, UserProfileEntity? profile})> updateProfile(
      UserProfileEntity profile) async {
    try {
      final response = await _dioClient.patch<Map<String, dynamic>>(
        '/profile/',
        data: {
          'first_name': profile.firstName,
          'last_name': profile.lastName,
          'display_name': profile.displayName,
          'bio': profile.bio,
          'favorite_genre': profile.favoriteGenre,
          'favorite_artist': profile.favoriteArtist,
          'listening_goal': profile.listeningGoal,
          'timezone': profile.timezone,
          'country': profile.country,
        },
      );
      final payload = response.data;
      if (payload != null &&
          payload['success'] == true &&
          payload['data'] != null) {
        final profileModel =
            UserProfileModel.fromJson(payload['data'] as Map<String, dynamic>);
        return (failure: null, profile: profileModel);
      }
      return (
        failure: const ServerFailure(message: 'Profile update failed.'),
        profile: null
      );
    } on DioException catch (e) {
      return (
        failure: NetworkFailure(message: 'Update error: ${e.message}'),
        profile: null
      );
    } catch (e) {
      return (
        failure: UnknownFailure(message: 'Update error: $e'),
        profile: null
      );
    }
  }

  @override
  Future<({Failure? failure, UserProfileEntity? profile})> uploadAvatar(
      String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/profile/avatar/',
        data: formData,
      );
      final payload = response.data;
      if (payload != null &&
          payload['success'] == true &&
          payload['data'] != null) {
        final profileModel =
            UserProfileModel.fromJson(payload['data'] as Map<String, dynamic>);
        return (failure: null, profile: profileModel);
      }
      return (
        failure: const ServerFailure(message: 'Avatar upload failed.'),
        profile: null
      );
    } on DioException catch (e) {
      return (
        failure: NetworkFailure(message: 'Avatar upload error: ${e.message}'),
        profile: null
      );
    } catch (e) {
      return (
        failure: UnknownFailure(message: 'Avatar error: $e'),
        profile: null
      );
    }
  }

  @override
  Future<({Failure? failure, InvitationEntity? invitation})>
      createInvite() async {
    try {
      final response =
          await _dioClient.post<Map<String, dynamic>>('/relationship/invite/');
      final payload = response.data;
      if (payload != null &&
          payload['success'] == true &&
          payload['data'] != null) {
        final model =
            InvitationModel.fromJson(payload['data'] as Map<String, dynamic>);
        return (failure: null, invitation: model);
      }
      final msg = payload?['message'] as String? ?? 'Invite creation failed.';
      return (failure: ServerFailure(message: msg), invitation: null);
    } on DioException catch (e) {
      return (
        failure: NetworkFailure(message: 'Invite error: ${e.message}'),
        invitation: null
      );
    } catch (e) {
      return (
        failure: UnknownFailure(message: 'Invite error: $e'),
        invitation: null
      );
    }
  }

  @override
  Future<({Failure? failure, CoupleEntity? relationship})> acceptInvite(
      String code) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/relationship/accept/',
        data: {'code': code.trim()},
      );
      final payload = response.data;
      if (payload != null &&
          payload['success'] == true &&
          payload['data'] != null) {
        final model =
            CoupleModel.fromJson(payload['data'] as Map<String, dynamic>);
        return (failure: null, relationship: model);
      }
      final msg =
          payload?['message'] as String? ?? 'Failed to accept invitation code.';
      return (failure: ServerFailure(message: msg), relationship: null);
    } on DioException catch (e) {
      String msg = 'Failed to accept code.';
      if (e.response?.data is Map && e.response!.data['message'] != null) {
        msg = e.response!.data['message'].toString();
      }
      return (failure: NetworkFailure(message: msg), relationship: null);
    } catch (e) {
      return (
        failure: UnknownFailure(message: 'Accept error: $e'),
        relationship: null
      );
    }
  }

  @override
  Future<Failure?> rejectInvite(String code) async {
    try {
      await _dioClient.post<dynamic>(
        '/relationship/reject/',
        data: {'code': code.trim()},
      );
      return null;
    } catch (e) {
      return NetworkFailure(message: 'Reject error: $e');
    }
  }

  @override
  Future<
      ({
        Failure? failure,
        CoupleEntity? relationship,
        InvitationEntity? pendingInvitation
      })> getRelationship() async {
    try {
      final response =
          await _dioClient.get<Map<String, dynamic>>('/relationship/');
      final payload = response.data;
      if (payload != null &&
          payload['success'] == true &&
          payload['data'] != null) {
        final data = payload['data'] as Map<String, dynamic>;
        CoupleEntity? rel;
        InvitationEntity? inv;

        if (data['relationship'] != null) {
          rel = CoupleModel.fromJson(
              data['relationship'] as Map<String, dynamic>);
        }
        if (data['pendingInvitation'] != null) {
          inv = InvitationModel.fromJson(
              data['pendingInvitation'] as Map<String, dynamic>);
        }
        return (failure: null, relationship: rel, pendingInvitation: inv);
      }
      return (failure: null, relationship: null, pendingInvitation: null);
    } on DioException catch (e) {
      return (
        failure:
            NetworkFailure(message: 'Relationship fetch error: ${e.message}'),
        relationship: null,
        pendingInvitation: null
      );
    } catch (e) {
      return (
        failure: UnknownFailure(message: 'Relationship error: $e'),
        relationship: null,
        pendingInvitation: null
      );
    }
  }

  @override
  Future<Failure?> removeRelationship() async {
    try {
      await _dioClient.delete<dynamic>('/relationship/');
      return null;
    } catch (e) {
      return NetworkFailure(message: 'Failed to remove partner: $e');
    }
  }

  @override
  Future<({Failure? failure, UserProfileEntity? partner})>
      getPartnerProfile() async {
    try {
      final response =
          await _dioClient.get<Map<String, dynamic>>('/relationship/partner/');
      final payload = response.data;
      if (payload != null &&
          payload['success'] == true &&
          payload['data'] != null) {
        final model =
            UserProfileModel.fromJson(payload['data'] as Map<String, dynamic>);
        return (failure: null, partner: model);
      }
      return (
        failure: const ServerFailure(message: 'No active partner.'),
        partner: null
      );
    } catch (e) {
      return (
        failure: NetworkFailure(message: 'Partner fetch error: $e'),
        partner: null
      );
    }
  }
}
