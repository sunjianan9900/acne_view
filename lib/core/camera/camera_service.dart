import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 相机服务抽象层，支持内置摄像头与外接 UVC 摄像头（iPad）。
abstract class CameraService {
  Future<List<CameraDeviceInfo>> listDevices();
  Future<void> initialize({String? preferredDeviceId});
  Future<void> dispose();
  Future<String> takePicture({int jpegQuality = 85});
  Widget buildPreview();
  bool get isInitialized;
  bool get hasExternalCamera;
  CameraDeviceInfo? get currentDevice;
}

class CameraDeviceInfo {
  const CameraDeviceInfo({
    required this.id,
    required this.name,
    required this.isExternal,
  });

  final String id;
  final String name;
  final bool isExternal;
}

/// 照片本地存储
class PhotoStorage {
  static Future<String> savePhoto({
    required String spotId,
    required String sourcePath,
    required DateTime capturedAt,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final spotDir = Directory(p.join(dir.path, 'photos', spotId));
    if (!spotDir.existsSync()) {
      await spotDir.create(recursive: true);
    }
    final fileName =
        '${capturedAt.millisecondsSinceEpoch}.jpg';
    final destPath = p.join(spotDir.path, fileName);
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  static Future<void> deletePhoto(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
