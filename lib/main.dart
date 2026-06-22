import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/camera/camera_factory.dart';
import 'core/providers/camera_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameraService = await createCameraService();

  runApp(
    ProviderScope(
      overrides: [
        cameraServiceProvider.overrideWithValue(cameraService),
      ],
      child: const DoujiApp(),
    ),
  );
}
