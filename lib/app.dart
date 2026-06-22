import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';

import '../features/acne_education/acne_education_screen.dart';
import '../features/capture/capture_screen.dart';
import '../features/check_in/check_in_screen.dart';
import '../features/face_map/face_map_screen.dart';
import '../features/face_map/region_spots_screen.dart';
import '../features/help/help_screen.dart';
import '../features/home/home_screen.dart';
import '../features/preview/live_preview_screen.dart';
import '../features/tag_management/tag_management_screen.dart';
import '../features/timeline/timeline_screen.dart';
import 'shared/models/photo_source.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      pageBuilder: (context, state, child) {
        return NoTransitionPage<void>(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/face-map',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: FaceMapScreen(),
          ),
        ),
        GoRoute(
          path: '/acne-education',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AcneEducationScreen(),
          ),
        ),
        GoRoute(
          path: '/tag-management',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TagManagementScreen(),
          ),
        ),
        GoRoute(
          path: '/live-preview',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LivePreviewScreen(),
          ),
        ),
        GoRoute(
          path: '/region/:regionId',
          pageBuilder: (context, state) {
            final regionId = state.pathParameters['regionId']!;
            return NoTransitionPage(
              child: RegionSpotsScreen(regionId: regionId),
            );
          },
        ),
        GoRoute(
          path: '/capture/:spotId',
          pageBuilder: (context, state) {
            final spotId = state.pathParameters['spotId']!;
            return NoTransitionPage(child: CaptureScreen(spotId: spotId));
          },
        ),
        GoRoute(
          path: '/check-in',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return NoTransitionPage(
              child: CheckInScreen(
                spotId: extra['spotId'] as String,
                photoPath: extra['photoPath'] as String,
                photoSource: extra['photoSource'] as PhotoSource?,
                isExternalCamera: extra['isExternalCamera'] as bool? ?? false,
              ),
            );
          },
        ),
        GoRoute(
          path: '/timeline/:spotId',
          pageBuilder: (context, state) {
            final spotId = state.pathParameters['spotId']!;
            return NoTransitionPage(child: TimelineScreen(spotId: spotId));
          },
        ),
        GoRoute(
          path: '/help',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HelpScreen(),
          ),
        ),
      ],
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
