import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/network/dio_client.dart';
import 'package:soulsync/features/home/presentation/providers/dashboard_provider.dart';
import 'package:soulsync/features/profile/data/repositories/profile_api_repository_impl.dart';
import 'package:soulsync/features/profile/domain/entities/couple_entity.dart';
import 'package:soulsync/features/profile/domain/entities/invitation_entity.dart';
import 'package:soulsync/features/profile/domain/entities/user_profile_entity.dart';
import 'package:soulsync/features/profile/domain/repositories/profile_repository.dart';
import 'package:soulsync/features/realtime/presentation/providers/realtime_providers.dart';
import 'package:soulsync/features/realtime/services/web_socket_service.dart';
import 'package:soulsync/features/room/presentation/providers/room_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProfileApiRepositoryImpl(dioClient);
});

// Profile State
class UserProfileState {
  final UserProfileEntity? profile;
  final bool isLoading;
  final String? errorMessage;

  const UserProfileState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  UserProfileState copyWith({
    UserProfileEntity? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final ProfileRepository _repository;

  UserProfileNotifier(this._repository) : super(const UserProfileState()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getProfile();
    if (result.failure != null) {
      state = state.copyWith(
          isLoading: false, errorMessage: result.failure!.message);
    } else {
      state = state.copyWith(isLoading: false, profile: result.profile);
    }
  }

  Future<bool> updateProfile(UserProfileEntity updated) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.updateProfile(updated);
    if (result.failure != null) {
      state = state.copyWith(
          isLoading: false, errorMessage: result.failure!.message);
      return false;
    } else {
      state = state.copyWith(isLoading: false, profile: result.profile);
      return true;
    }
  }

  Future<bool> uploadAvatar(String filePath) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.uploadAvatar(filePath);
    if (result.failure != null) {
      state = state.copyWith(
          isLoading: false, errorMessage: result.failure!.message);
      return false;
    } else {
      state = state.copyWith(isLoading: false, profile: result.profile);
      return true;
    }
  }
}

final profileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return UserProfileNotifier(repo);
});

// Relationship State
class RelationshipState {
  final CoupleEntity? relationship;
  final InvitationEntity? pendingInvitation;
  final UserProfileEntity? partner;
  final bool isLoading;
  final String? errorMessage;

  const RelationshipState({
    this.relationship,
    this.pendingInvitation,
    this.partner,
    this.isLoading = false,
    this.errorMessage,
  });

  RelationshipState copyWith({
    CoupleEntity? relationship,
    InvitationEntity? pendingInvitation,
    UserProfileEntity? partner,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RelationshipState(
      relationship: relationship ?? this.relationship,
      pendingInvitation: pendingInvitation ?? this.pendingInvitation,
      partner: partner ?? this.partner,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RelationshipNotifier extends StateNotifier<RelationshipState> {
  final ProfileRepository _repository;
  final WebSocketService _wsService;
  final Ref _ref;
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  RelationshipNotifier(this._repository, this._wsService, this._ref)
      : super(const RelationshipState()) {
    fetchRelationship();
    _initWsListener();
  }

  void _initWsListener() {
    _wsSub = _wsService.messageStream.listen((data) {
      _handleWsMessage(data);
    });
  }

  void _handleWsMessage(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final event = data['event'] as String? ?? data['status'] as String? ?? data['payload']?['event'] as String?;

    if (event == 'relationship_removed' ||
        event == 'removed' ||
        type == 'relationship_removed') {
      state = const RelationshipState(isLoading: false);
      _ref.read(partnerPresenceNotifierProvider.notifier).reset();
      _ref.read(profileNotifierProvider.notifier).fetchProfile();
      _ref.read(roomNotifierProvider.notifier).leaveRoom();
      _ref.invalidate(dashboardDataProvider);
    } else if (event == 'relationship_created' ||
        event == 'accepted' ||
        type == 'relationship_created' ||
        (type == 'relationship_update' && event != 'relationship_removed' && event != 'removed')) {
      fetchRelationship();
      _ref.read(profileNotifierProvider.notifier).fetchProfile();
      _ref.invalidate(dashboardDataProvider);
    }
  }

  Future<void> fetchRelationship() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final relResult = await _repository.getRelationship();
    if (relResult.failure != null) {
      state = state.copyWith(
          isLoading: false, errorMessage: relResult.failure!.message);
      return;
    }

    UserProfileEntity? partnerObj;
    if (relResult.relationship != null) {
      final partnerResult = await _repository.getPartnerProfile();
      partnerObj = partnerResult.partner;
    }

    state = RelationshipState(
      isLoading: false,
      relationship: relResult.relationship,
      pendingInvitation: relResult.pendingInvitation,
      partner: partnerObj,
    );
  }

  Future<bool> createInvite() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.createInvite();
    if (result.failure != null) {
      state = state.copyWith(
          isLoading: false, errorMessage: result.failure!.message);
      return false;
    } else {
      state = state.copyWith(
          isLoading: false, pendingInvitation: result.invitation);
      return true;
    }
  }

  Future<bool> acceptInvite(String code) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.acceptInvite(code);
    if (result.failure != null) {
      state = state.copyWith(
          isLoading: false, errorMessage: result.failure!.message);
      return false;
    } else {
      await fetchRelationship();
      _wsService.send({
        'type': 'relationship_update',
        'event': 'relationship_created',
        'status': 'accepted',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      _ref.read(profileNotifierProvider.notifier).fetchProfile();
      _ref.invalidate(dashboardDataProvider);
      return true;
    }
  }

  Future<bool> removeRelationship() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final failure = await _repository.removeRelationship();
    if (failure != null) {
      state = state.copyWith(isLoading: false, errorMessage: failure.message);
      return false;
    } else {
      _wsService.send({
        'type': 'relationship_update',
        'event': 'relationship_removed',
        'status': 'removed',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      state = const RelationshipState(isLoading: false);
      _ref.read(partnerPresenceNotifierProvider.notifier).reset();
      _ref.read(profileNotifierProvider.notifier).fetchProfile();
      _ref.read(roomNotifierProvider.notifier).leaveRoom();
      _ref.invalidate(dashboardDataProvider);
      return true;
    }
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }
}

final relationshipNotifierProvider =
    StateNotifierProvider<RelationshipNotifier, RelationshipState>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  final ws = ref.watch(webSocketServiceProvider);
  return RelationshipNotifier(repo, ws, ref);
});
