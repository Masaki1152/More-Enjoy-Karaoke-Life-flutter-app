import 'package:go_router/go_router.dart';
import 'package:more_enjoy_karaoke_life/screens/screens.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/game_list',
      builder: (context, state) => const GameListScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile_edit',
      builder: (context, state) => const ProfileEditScreen(),
    ),
    GoRoute(
      path: '/room-entry',
      builder: (_, __) => const RoomEntryScreen(),
    ),
    GoRoute(
      path: '/room/:code/lobby',
      builder: (context, state) {
        final code = state.pathParameters['code']!;
        return RoomLobbyScreen(roomCode: code);
      },
    ),
    GoRoute(
      path: '/room/:code/shuffle',
      builder: (context, state) {
        final code = state.pathParameters['code']!;
        return TeamShuffleScreen(roomCode: code);
      },
    ),
    GoRoute(
      path: '/room/:code/best-match',
      builder: (context, state) {
        final code = state.pathParameters['code']!;
        return BestMatchScreen(roomCode: code);
      },
    ),
    GoRoute(
      path: '/room/:code/team-settings',
      builder: (context, state) {
        final code = state.pathParameters['code']!;
        return TeamSettingsScreen(roomCode: code);
      },
    ),
    GoRoute(
      path: '/room/:code/result',
      builder: (context, state) {
        final code = state.pathParameters['code']!;
        return GameResultScreen(roomCode: code);
      },
    ),
    GoRoute(
      path: '/error',
      builder: (context, state) {
        final String? message = state.extra as String?;
        return ErrorScreen(errorMessage: message);
      },
    ),
  ],
);