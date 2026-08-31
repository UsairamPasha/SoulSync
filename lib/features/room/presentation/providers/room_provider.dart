import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soulsync/core/logger/app_logger.dart';
import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';
import 'package:soulsync/features/realtime/presentation/providers/realtime_providers.dart';
import 'package:soulsync/features/realtime/services/web_socket_service.dart';
import 'package:soulsync/features/room/data/repositories/mock_room_repository_impl.dart';
import 'package:soulsync/features/room/domain/entities/couple_room_entity.dart';
import 'package:soulsync/features/room/domain/entities/listening_session_entity.dart';
import 'package:soulsync/features/room/domain/entities/room_member_entity.dart';
import 'package:soulsync/features/room/domain/repositories/room_repository.dart';

enum RoomLifecycleState {
  noRoom,
  createRoom,
  roomCreated,
  waitingForPartner,
  partnerJoined,
  readyToListen,
  listeningTogether,
  roomEnded,
}

@immutable
class RoomState {
  final CoupleRoomEntity? room;
  final List<RoomMemberEntity> members;
  final ListeningSessionEntity? session;
  final bool isLoading;
  final String? errorMessage;

  const RoomState({
    this.room,
    this.members = const [],
    this.session,
    this.isLoading = false,
    this.errorMessage,
  });

  RoomLifecycleState get lifecycleState {
    if (room == null) return RoomLifecycleState.noRoom;
    if (session != null) {
      return session!.isPlaying
          ? RoomLifecycleState.listeningTogether
          : RoomLifecycleState.readyToListen;
    }
    if (members.length > 1 || room!.isPartnerConnected) {
      return RoomLifecycleState.partnerJoined;
    }
    return RoomLifecycleState.waitingForPartner;
  }

  RoomState copyWith({
    CoupleRoomEntity? room,
    List<RoomMemberEntity>? members,
    ListeningSessionEntity? session,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RoomState(
      room: room ?? this.room,
      members: members ?? this.members,
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class RoomNotifier extends StateNotifier<RoomState> {
  final RoomRepository _repository;
  final WebSocketService _wsService;
  final Ref _ref;
  StreamSubscription<List<RoomMemberEntity>>? _membersSub;
  StreamSubscription<ListeningSessionEntity>? _sessionSub;
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  RoomNotifier(this._repository, this._wsService, this._ref)
      : super(const RoomState()) {
    _loadInitialRoom();
    _initWsListener();
  }

  void _initWsListener() {
    _wsSub = _wsService.messageStream.listen((data) {
      _handleWsMessage(data);
    });
  }

  void _handleWsMessage(Map<String, dynamic> data) {
    AppLogger.debug('[RoomNotifier] WebSocket room event received: $data');
    final type = data['type'] as String?;
    final event = data['event'] as String? ?? data['payload']?['event'] as String?;

    if (type == 'partner_joined' || event == 'partner_joined') {
      _handlePartnerJoined(data);
    } else if (type == 'partner_left' || event == 'partner_left') {
      _handlePartnerLeft(data);
    } else if (type == 'room_created' || event == 'room_created') {
      _handleRoomCreated(data);
    } else if (type == 'room_ended' ||
        type == 'room_closed' ||
        type == 'room_left' ||
        event == 'room_ended' ||
        event == 'room_closed' ||
        event == 'room_left') {
      _handleRoomClosed(data);
    }
  }

  void _handleRoomCreated(Map<String, dynamic> data) {
    if (state.room == null) {
      _loadInitialRoom();
    }
  }

  void _handlePartnerJoined(Map<String, dynamic> data) {
    if (state.room != null) {
      final updatedRoom = state.room!.copyWith(isPartnerConnected: true);
      final updatedMembers = List<RoomMemberEntity>.from(state.members);
      if (updatedMembers.length < 2) {
        updatedMembers.add(
          const RoomMemberEntity(
            id: 'user_partner_2',
            displayName: 'Partner',
            isHost: false,
            isOnline: true,
            statusMessage: 'Joined via invite code',
          ),
        );
      }
      state = state.copyWith(
        room: updatedRoom,
        members: updatedMembers,
      );
    }
  }

  void _handlePartnerLeft(Map<String, dynamic> data) {
    _closeRoomAndCleanup();
  }

  void _handleRoomClosed(Map<String, dynamic> data) {
    _closeRoomAndCleanup();
  }

  void _closeRoomAndCleanup() {
    _membersSub?.cancel();
    _sessionSub?.cancel();
    _ref.read(playbackSessionNotifierProvider.notifier).clearSessionState();
    _ref.read(playerNotifierProvider.notifier).pauseSong();
    state = const RoomState();
  }

  Future<void> refreshActiveRoom() async {
    try {
      final room = await _repository.getCurrentRoom();
      if (room != null) {
        final members = await _repository.getRoomMembers(room.id);
        state = state.copyWith(
          room: room.copyWith(isPartnerConnected: true),
          members: members,
        );
        _listenToRoomEvents(room.id);
        _wsService.send({
          'type': 'room_update',
          'event': 'presence_reasserted',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      debugPrint('[RoomNotifier] Refresh active room error: $e');
    }
  }

  Future<void> _loadInitialRoom() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final room = await _repository.getCurrentRoom();
      if (room != null) {
        final members = await _repository.getRoomMembers(room.id);
        state = state.copyWith(
          room: room,
          members: members,
          isLoading: false,
        );
        _listenToRoomEvents(room.id);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint('[RoomNotifier] Room load warning: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load room details.',
      );
    }
  }

  void _listenToRoomEvents(String roomId) {
    _membersSub?.cancel();
    _membersSub = _repository.watchRoomMembers(roomId).listen(
      (members) {
        state = state.copyWith(members: members);
      },
      onError: (Object err) {
        debugPrint('[RoomNotifier] Watch members error: $err');
      },
    );

    _sessionSub?.cancel();
    _sessionSub = _repository.watchListeningSession(roomId).listen(
      (session) {
        state = state.copyWith(session: session);
      },
      onError: (Object err) {
        debugPrint('[RoomNotifier] Watch session error: $err');
      },
    );
  }

  Future<bool> createRoom(String roomName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newRoom = await _repository.createRoom(roomName);
      final members = await _repository.getRoomMembers(newRoom.id);
      state = state.copyWith(
        room: newRoom,
        members: members,
        isLoading: false,
      );
      _listenToRoomEvents(newRoom.id);

      _wsService.send({
        'type': 'room_update',
        'event': 'room_created',
        'name': roomName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create room.',
      );
      return false;
    }
  }

  Future<bool> joinRoom(String inviteCode) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final joinedRoom = await _repository.joinRoom(inviteCode);
      final members = await _repository.getRoomMembers(joinedRoom.id);
      state = state.copyWith(
        room: joinedRoom,
        members: members,
        isLoading: false,
      );
      _listenToRoomEvents(joinedRoom.id);

      _wsService.send({
        'type': 'partner_joined',
        'event': 'partner_joined',
        'inviteCode': inviteCode,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid room invite code.',
      );
      return false;
    }
  }

  Future<void> leaveRoom() async {
    if (state.room != null) {
      _wsService.send({
        'type': 'room_closed',
        'event': 'room_closed',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      try {
        await _repository.leaveRoom(state.room!.id);
      } catch (e) {
        debugPrint('[RoomNotifier] Leave room warning: $e');
      }
      _closeRoomAndCleanup();
    }
  }

  Future<void> endRoom() async {
    if (state.room != null) {
      _wsService.send({
        'type': 'room_closed',
        'event': 'room_closed',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      try {
        await _repository.endListeningSession(state.room!.id);
        await _repository.leaveRoom(state.room!.id);
      } catch (e) {
        debugPrint('[RoomNotifier] End room warning: $e');
      }
      _closeRoomAndCleanup();
    }
  }

  Future<void> cancelRoom() async {
    await leaveRoom();
  }

  Future<({bool success, String? message})> startListeningSession() async {
    if (state.room == null) {
      return (
        success: false,
        message: 'No active room found. Please create or join a room first.'
      );
    }
    if (state.members.length < 2 && !state.room!.isPartnerConnected) {
      return (
        success: false,
        message: 'Partner is not connected yet. Waiting for partner to join.'
      );
    }
    try {
      final session = await _repository.startListeningSession(state.room!.id);
      state = state.copyWith(session: session);
      return (
        success: true,
        message: 'Listening session started successfully!'
      );
    } catch (e) {
      debugPrint('[RoomNotifier] Start listening session error: $e');
      return (
        success: false,
        message: 'Unable to start session at this time.'
      );
    }
  }

  @override
  void dispose() {
    _membersSub?.cancel();
    _sessionSub?.cancel();
    _wsSub?.cancel();
    super.dispose();
  }
}

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return MockRoomRepositoryImpl();
});

final roomNotifierProvider =
    StateNotifierProvider<RoomNotifier, RoomState>((ref) {
  final repo = ref.watch(roomRepositoryProvider);
  final ws = ref.watch(webSocketServiceProvider);
  return RoomNotifier(repo, ws, ref);
});
