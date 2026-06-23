import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class UvcCameraDevice {
  const UvcCameraDevice({
    required this.id,
    required this.name,
    required this.isExternal,
  });

  final String id;
  final String name;
  final bool isExternal;

  factory UvcCameraDevice.fromMap(Map<dynamic, dynamic> map) {
    return UvcCameraDevice(
      id: map['id'] as String,
      name: map['name'] as String,
      isExternal: map['isExternal'] as bool? ?? false,
    );
  }
}

class AcneUvcCameraMacos {
  static const MethodChannel _channel =
      MethodChannel('acne_uvc_camera_macos');
  static const EventChannel _eventChannel =
      EventChannel('acne_uvc_camera_macos/events');

  static Future<bool> get isSupported async {
    if (defaultTargetPlatform != TargetPlatform.macOS) return false;
    try {
      final result = await _channel.invokeMethod<bool>('isSupported');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<List<UvcCameraDevice>> listDevices() async {
    final result = await _channel.invokeMethod<List<dynamic>>('listDevices');
    if (result == null) return [];
    return result
        .map((e) => UvcCameraDevice.fromMap(e as Map<dynamic, dynamic>))
        .toList();
  }

  static Future<bool> hasExternalCamera() async {
    final devices = await listDevices();
    return devices.any((d) => d.isExternal);
  }

  static Future<int> initialize({
    bool preferExternal = true,
    String? deviceId,
  }) async {
    final textureId = await _channel.invokeMethod<int>('initialize', {
      'preferExternal': preferExternal,
      if (deviceId != null) 'deviceId': deviceId,
    });
    return textureId ?? -1;
  }

  static Future<void> dispose() async {
    await _channel.invokeMethod<void>('dispose');
  }

  static Future<String> takePicture() async {
    final path = await _channel.invokeMethod<String>('takePicture');
    if (path == null) throw PlatformException(code: 'capture_failed');
    return path;
  }

  static Future<void> switchCamera() async {
    await _channel.invokeMethod<void>('switchCamera');
  }

  static Future<int> selectDevice(String deviceId) async {
    final textureId = await _channel.invokeMethod<int>('selectDevice', {
      'deviceId': deviceId,
    });
    return textureId ?? -1;
  }

  static Stream<String> get connectionEvents {
    return _eventChannel.receiveBroadcastStream().map((e) => e as String);
  }
}
