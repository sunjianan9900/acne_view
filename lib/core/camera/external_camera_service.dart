import 'package:flutter/material.dart';

import 'camera_service.dart';
import 'capture_aspect.dart';
import 'uvc_camera_client.dart';

/// 外接 UVC 摄像头实现（iPad / macOS USB 摄像头）
class ExternalCameraService implements CameraService {
  int _textureId = -1;
  bool _initialized = false;
  List<CameraDeviceInfo> _devices = [];
  String? _currentDeviceId;

  @override
  bool get isInitialized => _initialized && _textureId >= 0;

  @override
  bool get hasExternalCamera => _devices.any((d) => d.isExternal);

  @override
  CameraDeviceInfo? get currentDevice {
    if (_currentDeviceId == null) return null;
    try {
      return _devices.firstWhere((d) => d.id == _currentDeviceId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<CameraDeviceInfo>> listDevices() async {
    final supported = await UvcCamera.isSupported;
    if (!supported) return [];

    final devices = await UvcCamera.listDevices();
    _devices = devices
        .map(
          (d) => CameraDeviceInfo(
            id: d.id,
            name: d.isExternal ? '${d.name}（外接）' : d.name,
            isExternal: d.isExternal,
          ),
        )
        .toList();
    return _devices;
  }

  @override
  Future<void> initialize({String? preferredDeviceId}) async {
    final supported = await UvcCamera.isSupported;
    if (!supported) {
      throw Exception('当前设备不支持外接 UVC 摄像头');
    }

    await listDevices();
    _textureId = await UvcCamera.initialize(
      preferExternal: preferredDeviceId == null,
      deviceId: preferredDeviceId,
    );
    _initialized = _textureId >= 0;

    if (!_initialized) return;

    if (preferredDeviceId != null) {
      _currentDeviceId = preferredDeviceId;
      return;
    }

    final external = _devices.where((d) => d.isExternal);
    if (external.isNotEmpty) {
      _currentDeviceId = external.first.id;
    } else if (_devices.isNotEmpty) {
      _currentDeviceId = _devices.first.id;
    }
  }

  @override
  double? get previewAspectRatio => kCaptureAspectRatio;

  @override
  Future<void> dispose() async {
    await UvcCamera.dispose();
    _initialized = false;
    _textureId = -1;
  }

  @override
  Future<String> takePicture({int jpegQuality = 85}) async {
    if (!isInitialized) {
      throw Exception('相机未初始化');
    }
    return UvcCamera.takePicture();
  }

  @override
  Future<void> selectDevice(String deviceId) async {
    if (_currentDeviceId == deviceId && isInitialized) return;
    _textureId = await UvcCamera.selectDevice(deviceId);
    _initialized = _textureId >= 0;
    if (_initialized) {
      _currentDeviceId = deviceId;
    }
    await listDevices();
  }

  Future<void> switchCamera() async {
    await UvcCamera.switchCamera();
    await listDevices();
    final devices = await UvcCamera.listDevices();
    if (devices.isNotEmpty) {
      _currentDeviceId = devices.first.id;
    }
  }

  @override
  Widget buildPreview() {
    if (!isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Transform.flip(flipX: true, child: Texture(textureId: _textureId));
  }
}
