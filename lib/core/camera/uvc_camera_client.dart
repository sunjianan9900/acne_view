import 'dart:io';

import 'package:acne_uvc_camera_ios/acne_uvc_camera_ios.dart' as ios;
import 'package:acne_uvc_camera_macos/acne_uvc_camera_macos.dart' as macos;
import 'package:flutter/foundation.dart';

export 'package:acne_uvc_camera_ios/acne_uvc_camera_ios.dart' show UvcCameraDevice;

/// 跨平台 UVC 相机 API（iOS iPad / macOS）
class UvcCamera {
  static bool get _isIos => !kIsWeb && Platform.isIOS;
  static bool get _isMacOS => !kIsWeb && Platform.isMacOS;

  static Future<bool> get isSimulator async {
    if (_isIos) return ios.AcneUvcCameraIos.isSimulator;
    return false;
  }

  static Future<bool> get isSupported async {
    if (_isIos) return ios.AcneUvcCameraIos.isSupported;
    if (_isMacOS) return macos.AcneUvcCameraMacos.isSupported;
    return false;
  }

  static Future<List<ios.UvcCameraDevice>> listDevices() async {
    if (_isIos) return ios.AcneUvcCameraIos.listDevices();
    if (_isMacOS) {
      final devices = await macos.AcneUvcCameraMacos.listDevices();
      return devices
          .map(
            (d) => ios.UvcCameraDevice(
              id: d.id,
              name: d.name,
              isExternal: d.isExternal,
            ),
          )
          .toList();
    }
    return [];
  }

  static Future<bool> hasExternalCamera() async {
    final devices = await listDevices();
    return devices.any((d) => d.isExternal);
  }

  static Future<int> initialize({bool preferExternal = true}) async {
    if (_isIos) {
      return ios.AcneUvcCameraIos.initialize(preferExternal: preferExternal);
    }
    if (_isMacOS) {
      return macos.AcneUvcCameraMacos.initialize(preferExternal: preferExternal);
    }
    return -1;
  }

  static Future<void> dispose() async {
    if (_isIos) return ios.AcneUvcCameraIos.dispose();
    if (_isMacOS) return macos.AcneUvcCameraMacos.dispose();
  }

  static Future<String> takePicture() async {
    if (_isIos) return ios.AcneUvcCameraIos.takePicture();
    if (_isMacOS) return macos.AcneUvcCameraMacos.takePicture();
    throw UnsupportedError('UVC camera not supported on this platform');
  }

  static Future<void> switchCamera() async {
    if (_isIos) return ios.AcneUvcCameraIos.switchCamera();
    if (_isMacOS) return macos.AcneUvcCameraMacos.switchCamera();
  }
}
