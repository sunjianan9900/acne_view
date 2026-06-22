import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../camera/camera_service.dart';

final cameraServiceProvider = Provider<CameraService>((ref) {
  throw UnimplementedError(
    'cameraServiceProvider must be overridden in main()',
  );
});
