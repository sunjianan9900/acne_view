import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:acne_view/app.dart';
import 'package:acne_view/core/camera/builtin_camera_service.dart';
import 'package:acne_view/core/database/database.dart';
import 'package:acne_view/core/providers/camera_provider.dart';
import 'package:acne_view/core/providers/repositories.dart';
import 'package:acne_view/features/face_map/widgets/face_map_painter.dart';
import 'package:acne_view/shared/models/face_region.dart';
import 'package:acne_view/shared/models/spot_status.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cameraServiceProvider.overrideWithValue(BuiltinCameraService()),
          allSpotsProvider.overrideWith(
            (ref) => Stream<List<AcneSpot>>.value(const []),
          ),
        ],
        child: const DoujiApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('我的痘痘'), findsWidgets);
    expect(find.text('新增痘痘'), findsOneWidget);
  });

  testWidgets('desktop tab switch keeps the shell steady', (tester) async {
    tester.view.physicalSize = const Size(1440, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cameraServiceProvider.overrideWithValue(BuiltinCameraService()),
          allSpotsProvider.overrideWith(
            (ref) => Stream<List<AcneSpot>>.value(const []),
          ),
        ],
        child: const DoujiApp(),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('我的痘痘'), findsWidgets);

    await tester.tap(find.text('痘痘地图'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('面部地图'), findsWidgets);
    expect(find.byType(SlideTransition), findsNothing);
  });

  testWidgets('desktop face region tap updates the right panel only', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final spots = <AcneSpot>[
      AcneSpot(
        id: 'spot-1',
        faceRegion: FaceRegion.forehead.id,
        createdAt: DateTime(2026, 1, 2),
        note: '',
        status: SpotStatus.active.id,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cameraServiceProvider.overrideWithValue(BuiltinCameraService()),
          allSpotsProvider.overrideWith(
            (ref) => Stream<List<AcneSpot>>.value(spots),
          ),
          spotsByRegionProvider(
            FaceRegion.forehead.id,
          ).overrideWith((ref) => Stream<List<AcneSpot>>.value(spots)),
          regionCountsProvider.overrideWith((ref) async {
            return {for (final region in FaceRegion.values) region.id: 0};
          }),
        ],
        child: const DoujiApp(),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('面部地图'), findsWidgets);
    expect(find.text('已记录的痘痘 (1)'), findsOneWidget);

    await tester.tap(find.text('痘痘地图'));
    await tester.pumpAndSettle();

    final faceMap = find.descendant(
      of: find.byType(FaceMapWidget),
      matching: find.byType(GestureDetector),
    );
    expect(faceMap, findsOneWidget);
    final box = tester.getRect(faceMap);
    Offset? hitPoint;
    for (var x = 0.2; x <= 0.8 && hitPoint == null; x += 0.05) {
      for (var y = 0.08; y <= 0.32; y += 0.02) {
        final local = Offset(box.width * x, box.height * y);
        if (FaceMapPainter.hitTestRegion(local, box.size) ==
            FaceRegion.forehead) {
          hitPoint = box.topLeft + local;
          break;
        }
      }
    }
    expect(hitPoint, isNotNull);
    await tester.tapAt(hitPoint!);
    await tester.pumpAndSettle();

    expect(find.text('额头 · 痘痘列表'), findsOneWidget);
    expect(find.text('查看全部'), findsOneWidget);
    expect(find.text('痘痘地图'), findsWidgets);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
