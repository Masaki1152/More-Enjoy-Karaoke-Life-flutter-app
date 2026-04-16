import 'package:go_router/go_router.dart';
import 'package:more_enjoy_karaoke_life/screens/screens.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
  ],
);