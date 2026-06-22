import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:acne_view/app.dart';
import 'package:acne_view/core/camera/builtin_camera_service.dart';
import 'package:acne_view/core/providers/camera_provider.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cameraServiceProvider.overrideWithValue(BuiltinCameraService()),
        ],
        child: const DoujiApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('我的痘痘'), findsOneWidget);
    expect(find.text('面部地图'), findsOneWidget);
  });
}
