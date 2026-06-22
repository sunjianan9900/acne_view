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

class _SpySpotRepository implements AcneSpotRepository {
  _SpySpotRepository();

  String? lastUpdatedSpotId;
  String? lastUpdatedNote;

  @override
  Stream<List<AcneSpot>> watchAllSpots() =>
      Stream<List<AcneSpot>>.value(const []);

  @override
  Stream<List<AcneSpot>> watchSpotsByRegion(FaceRegion region) =>
      Stream<List<AcneSpot>>.value(const []);

  @override
  Stream<List<AcneSpot>> watchActiveSpots() =>
      Stream<List<AcneSpot>>.value(const []);

  @override
  Future<AcneSpot?> getSpot(String id) async => null;

  @override
  Future<String> createSpot({
    required FaceRegion region,
    String title = '',
    String note = '',
  }) async {
    return 'fake';
  }

  @override
  Future<void> updateSpotNote(String id, String note) async {
    lastUpdatedSpotId = id;
    lastUpdatedNote = note;
  }

  @override
  Future<void> updateSpotStatus(String id, SpotStatus status) async {}

  @override
  Future<void> deleteSpot(String id) async {}

  @override
  Future<Map<String, int>> getActiveCountByRegion() async => {
    for (final region in FaceRegion.values) region.id: 0,
  };

  @override
  Future<int> countActiveSpots() async => 0;
}

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    router.go('/');
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
    router.go('/');
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
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

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
    router.go('/');
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final spots = <AcneSpot>[
      AcneSpot(
        id: 'spot-1',
        title: '额头新痘',
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
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('痘痘地图'));
    await tester.pumpAndSettle();

    expect(find.text('已记录的痘痘 (1)'), findsOneWidget);

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

  testWidgets('desktop home splits timeline and note editor', (tester) async {
    tester.view.physicalSize = const Size(1440, 1024);
    tester.view.devicePixelRatio = 1.0;
    router.go('/');
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final spots = <AcneSpot>[
      AcneSpot(
        id: 'spot-home-1',
        title: '首页标题测试',
        faceRegion: FaceRegion.forehead.id,
        createdAt: DateTime(2026, 6, 22),
        note: '初始备注',
        status: SpotStatus.active.id,
      ),
    ];

    final repo = _SpySpotRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cameraServiceProvider.overrideWithValue(BuiltinCameraService()),
          allSpotsProvider.overrideWith(
            (ref) => Stream<List<AcneSpot>>.value(spots),
          ),
          spotRepositoryProvider.overrideWithValue(repo),
          spotTimelineProvider(
            'spot-home-1',
          ).overrideWith((ref) async => const []),
        ],
        child: const DoujiApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(
      find.descendant(
        of: find.byType(ListView),
        matching: find.text('首页标题测试'),
      ).first,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '新增备注内容');
    await tester.tap(find.text('保存备注'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('备注已保存'), findsOneWidget);
    expect(repo.lastUpdatedSpotId, 'spot-home-1');
    expect(repo.lastUpdatedNote, '新增备注内容');
  });
}
