import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:soulsync/features/notifications/domain/entities/notification_entity.dart';
import 'package:soulsync/features/realtime/presentation/providers/realtime_providers.dart';
import 'package:soulsync/features/realtime/services/web_socket_service.dart';

@immutable
class NotificationState {
  final List<NotificationEntity> notifications;
  final bool isLoading;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState()) {
    _loadInitialNotifications();
  }

  void _loadInitialNotifications() {
    state = const NotificationState(
      notifications: [],
      isLoading: false,
    );
  }

  void addNotification({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) {
    final newNotif = NotificationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
      isRead: false,
      data: data,
    );

    state = state.copyWith(
      notifications: [newNotif, ...state.notifications],
    );
  }

  void markAsRead(String id) {
    final updated = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: updated);
  }

  void markAllAsRead() {
    final updated =
        state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);
  }

  void clearNotification(String id) {
    final updated = state.notifications.where((n) => n.id != id).toList();
    state = state.copyWith(notifications: updated);
  }

  void clearAll() {
    state = state.copyWith(notifications: const []);
  }
}

class NotificationService {
  final WebSocketService _wsService;
  final Ref _ref;
  StreamSubscription<Map<String, dynamic>>? _sub;

  NotificationService(this._wsService, this._ref) {
    _initListener();
  }

  void _initListener() {
    _sub = _wsService.messageStream.listen((data) {
      _handleWsMessage(data);
    });
  }

  void _handleWsMessage(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final event = data['event'] as String? ?? data['status'] as String? ?? data['payload']?['event'] as String?;

    if (event == 'relationship_created' || event == 'accepted' || type == 'relationship_created') {
      _ref.read(notificationNotifierProvider.notifier).addNotification(
        title: 'Partner Linked',
        body: 'You are now linked with your partner!',
        type: NotificationType.relationshipInvite,
        data: {'targetRoute': '/profile/relationship'},
      );
    } else if (event == 'relationship_removed' || event == 'removed' || type == 'relationship_removed') {
      _ref.read(notificationNotifierProvider.notifier).addNotification(
        title: 'Partner Removed',
        body: 'Your couple relationship has ended.',
        type: NotificationType.systemAlert,
        data: {'targetRoute': '/profile'},
      );
    } else if (type == 'presence_update') {
      final isOnline = data['isOnline'] as bool? ?? false;
      if (isOnline) {
        _ref.read(notificationNotifierProvider.notifier).addNotification(
          title: 'Partner Online',
          body: 'Your partner is now online!',
          type: NotificationType.partnerJoined,
          data: {'targetRoute': '/home'},
        );
      } else {
        _ref.read(notificationNotifierProvider.notifier).addNotification(
          title: 'Partner Offline',
          body: 'Your partner went offline.',
          type: NotificationType.systemAlert,
          data: {'targetRoute': '/home'},
        );
      }
    } else if (type == 'room_created' || event == 'room_created') {
      _ref.read(notificationNotifierProvider.notifier).addNotification(
        title: 'Room Created',
        body: 'Private couple room created successfully.',
        type: NotificationType.partnerJoined,
        data: {'targetRoute': '/room'},
      );
    } else if (type == 'partner_joined' || event == 'partner_joined') {
      _ref.read(notificationNotifierProvider.notifier).addNotification(
        title: 'Partner Joined Room',
        body: 'Your partner joined your listening room!',
        type: NotificationType.partnerJoined,
        data: {'targetRoute': '/room'},
      );
    } else if (type == 'partner_left' || event == 'partner_left') {
      _ref.read(notificationNotifierProvider.notifier).addNotification(
        title: 'Partner Left Room',
        body: 'Your partner left the listening room.',
        type: NotificationType.systemAlert,
        data: {'targetRoute': '/room'},
      );
    } else if (type == 'room_ended' || type == 'room_closed' || event == 'room_ended' || event == 'room_closed') {
      _ref.read(notificationNotifierProvider.notifier).addNotification(
        title: 'Room Ended',
        body: 'The listening room was closed.',
        type: NotificationType.systemAlert,
        data: {'targetRoute': '/home'},
      );
    } else if (type == 'session_started' || event == 'session_started') {
      _ref.read(notificationNotifierProvider.notifier).addNotification(
        title: 'Session Started',
        body: 'Synchronized music listening session started!',
        type: NotificationType.sessionStarted,
        data: {'targetRoute': '/player'},
      );
    } else if (type == 'session_stopped' || event == 'session_stopped' || event == 'session_ended') {
      _ref.read(notificationNotifierProvider.notifier).addNotification(
        title: 'Session Ended',
        body: 'The listening session has ended.',
        type: NotificationType.systemAlert,
        data: {'targetRoute': '/room'},
      );
    } else if (type == 'chat_message') {
      final currentUserId = _ref.read(authNotifierProvider).user?.id ?? 'user_me';
      final senderId = data['senderId'] ?? data['sender_id'];
      if (senderId != null && senderId.toString() == currentUserId.toString()) return;

      final text = data['text'] as String? ?? 'Sent a message';
      _ref.read(notificationNotifierProvider.notifier).addNotification(
        title: '❤️ My Soulmate',
        body: text,
        type: NotificationType.chatMessage,
        data: {'targetRoute': '/chat'},
      );
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final ws = ref.watch(webSocketServiceProvider);
  final service = NotificationService(ws, ref);
  ref.onDispose(() => service.dispose());
  return service;
});

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  ref.watch(notificationServiceProvider);
  return NotificationNotifier();
});
