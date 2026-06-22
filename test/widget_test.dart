import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:acne_view/app.dart';
import 'package:acne_view/core/camera/builtin_camera_service.dart';
import 'package:acne_view/core/database/database.dart';
import 'package:acne_view/core/providers/camera_provider.dart';
import 'package:acne_view/core/providers/repositories.dart';

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
}
