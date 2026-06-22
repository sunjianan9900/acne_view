import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';

import '../features/capture/capture_screen.dart';
import '../features/check_in/check_in_screen.dart';
import '../features/face_map/face_map_screen.dart';
import '../features/face_map/region_spots_screen.dart';
import '../features/help/help_screen.dart';
import '../features/home/home_screen.dart';
import '../features/timeline/timeline_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/face-map',
      builder: (context, state) => const FaceMapScreen(),
    ),
    GoRoute(
      path: '/region/:regionId',
      builder: (context, state) {
        final regionId = state.pathParameters['regionId']!;
        return RegionSpotsScreen(regionId: regionId);
      },
    ),
    GoRoute(
      path: '/capture/:spotId',
      builder: (context, state) {
        final spotId = state.pathParameters['spotId']!;
        return CaptureScreen(spotId: spotId);
      },
    ),
    GoRoute(
      path: '/check-in',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return CheckInScreen(
          spotId: extra['spotId'] as String,
          photoPath: extra['photoPath'] as String,
          isExternalCamera: extra['isExternalCamera'] as bool? ?? false,
        );
      },
    ),
    GoRoute(
      path: '/timeline/:spotId',
      builder: (context, state) {
        final spotId = state.pathParameters['spotId']!;
        return TimelineScreen(spotId: spotId);
      },
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpScreen(),
    ),
  ],
);

class DoujiApp extends StatelessWidget {
  const DoujiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '痘迹',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
