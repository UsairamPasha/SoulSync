import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:soulsync/core/widgets/app_error_widget.dart';
import 'package:soulsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:soulsync/features/auth/presentation/screens/auth_screen.dart';
import 'package:soulsync/features/auth/presentation/screens/login_screen.dart';
import 'package:soulsync/features/auth/presentation/screens/register_screen.dart';
import 'package:soulsync/features/auth/presentation/screens/welcome_screen.dart';
import 'package:soulsync/features/chat/presentation/screens/chat_info_screen.dart';
import 'package:soulsync/features/chat/presentation/screens/chat_screen.dart';
import 'package:soulsync/features/chat/presentation/screens/chat_search_screen.dart';
import 'package:soulsync/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:soulsync/features/home/presentation/screens/home_screen.dart';
import 'package:soulsync/features/home/presentation/screens/splash_screen.dart';
import 'package:soulsync/features/notifications/presentation/screens/notification_screen.dart';
import 'package:soulsync/features/player/presentation/screens/player_screen.dart';
import 'package:soulsync/features/player/presentation/screens/recently_played_screen.dart';
import 'package:soulsync/features/playlist/presentation/screens/playlist_screen.dart';
import 'package:soulsync/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:soulsync/features/profile/presentation/screens/profile_screen.dart';
import 'package:soulsync/features/profile/presentation/screens/relationship_screen.dart';
import 'package:soulsync/features/room/presentation/screens/create_room_screen.dart';
import 'package:soulsync/features/room/presentation/screens/join_room_screen.dart';
import 'package:soulsync/features/room/presentation/screens/room_screen.dart';
import 'package:soulsync/features/settings/presentation/screens/settings_screen.dart';
import 'package:soulsync/features/showcase/presentation/screens/showcase_screen.dart';
import 'package:soulsync/shared/navigation/navigation_shell.dart';

/// Listenable adapter notifying GoRouter when Riverpod AuthState updates.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.read(routerNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: routerNotifier,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final status = authState.status;
      final location = state.matchedLocation;

      final isSplash = location == '/';
      final isAuthRoute = location == '/welcome' ||
          location == '/login' ||
          location == '/auth' ||
          location == '/register';

      // Stay on splash during initial auth verification or active authentication
      if (status == AuthStatus.initial || status == AuthStatus.authenticating) {
        return null;
      }

      // Unauthenticated users are guarded and redirected to /welcome
      if (status == AuthStatus.unauthenticated || status == AuthStatus.error) {
        if (!isAuthRoute) {
          return '/welcome';
        }
        return null;
      }

      // Authenticated users are redirected away from auth screens to /home
      if (status == AuthStatus.authenticated) {
        if (isAuthRoute || isSplash) {
          return '/home';
        }
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // Stateful Navigation Shell with 5 Persistent Bottom Navigation Tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/player',
                name: 'player',
                builder: (context, state) => const PlayerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/playlist',
                name: 'playlist',
                builder: (context, state) => const PlaylistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                name: 'chat',
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Standalone Routes Outside Bottom Navigation Shell
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/relationship',
        name: 'relationship',
        builder: (context, state) => const RelationshipScreen(),
      ),
      GoRoute(
        path: '/chat/conversation',
        name: 'chat-conversation',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/chat/search',
        name: 'chat-search',
        builder: (context, state) => const ChatSearchScreen(),
      ),
      GoRoute(
        path: '/chat/info',
        name: 'chat-info',
        builder: (context, state) => const ChatInfoScreen(),
      ),
      GoRoute(
        path: '/room',
        name: 'room',
        builder: (context, state) => const RoomScreen(),
      ),
      GoRoute(
        path: '/room/create',
        name: 'create-room',
        builder: (context, state) => const CreateRoomScreen(),
      ),
      GoRoute(
        path: '/room/join',
        name: 'join-room',
        builder: (context, state) => const JoinRoomScreen(),
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/recently-played',
        name: 'recently-played',
        builder: (context, state) => const RecentlyPlayedScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/showcase',
        name: 'showcase',
        builder: (context, state) => const ShowcaseScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: AppErrorWidget(
        message: state.error?.message ?? 'Page not found',
      ),
    ),
  );
});
