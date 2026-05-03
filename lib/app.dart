import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/discover_detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/route_view_screen.dart';
import 'screens/saved_spots_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/spot_add_screen.dart';
import 'screens/spot_detail_screen.dart';
import 'screens/trip_create_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'screens/trips_screen.dart';
import 'theme/app_theme.dart';

final _router = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navShell) => ShellScreen(navigationShell: navShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/saved',
            builder: (ctx, state) =>
                SavedSpotsScreen(initialRegion: state.uri.queryParameters['region']),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/trips', builder: (_, __) => const TripsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ]),
      ],
    ),
    GoRoute(path: '/spot/add', builder: (_, __) => const SpotAddScreen()),
    GoRoute(
      path: '/spot/:id',
      builder: (_, state) => SpotDetailScreen(spotId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/trip/new', builder: (_, __) => const TripCreateScreen()),
    GoRoute(
      path: '/trip/:id',
      builder: (_, state) => TripDetailScreen(tripId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/trip/:id/route',
      builder: (_, state) => RouteViewScreen(tripId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/discover/:guideId',
      builder: (_, state) =>
          DiscoverDetailScreen(guideId: state.pathParameters['guideId']!),
    ),
  ],
);

class TravelRouteApp extends StatelessWidget {
  const TravelRouteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Roamy',
      debugShowCheckedModeBanner: false,
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      routerConfig: _router,
    );
  }
}
