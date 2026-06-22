import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera_service.dart';

class BuiltinCameraService implements CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;

  @override
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  @override
  bool get hasExternalCamera => false;

  @override
  CameraDeviceInfo? get currentDevice {
    if (_cameras.isEmpty || _cameraIndex >= _cameras.length) return null;
    final cam = _cameras[_cameraIndex];
    return CameraDeviceInfo(
      id: cam.name,
      name: cam.lensDirection == CameraLensDirection.front ? '前置摄像头' : '后置摄像头',
      isExternal: false,
    );
  }

  @override
  Future<List<CameraDeviceInfo>> listDevices() async {
    _cameras = await availableCameras();
    return _cameras
        .map(
          (c) => CameraDeviceInfo(
            id: c.name,
            name: c.lensDirection == CameraLensDirection.front
                ? '前置摄像头'
                : '后置摄像头',
            isExternal: false,
          ),
        )
        .toList();
  }

  @override
  Future<void> initialize({String? preferredDeviceId}) async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    if (_cameras.isEmpty) {
      throw CameraException('no_camera', '未找到可用摄像头');
    }

    if (preferredDeviceId != null) {
      final idx = _cameras.indexWhere((c) => c.name == preferredDeviceId);
      if (idx >= 0) _cameraIndex = idx;
    } else {
      // 默认后置摄像头
      final backIdx = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      _cameraIndex = backIdx >= 0 ? backIdx : 0;
    }

    await _controller?.dispose();
    _controller = CameraController(
      _cameras[_cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _controller!.initialize();
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await initialize(preferredDeviceId: _cameras[_cameraIndex].name);
  }

  @override
  double? get previewAspectRatio {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return null;
    return controller.value.aspectRatio;
  }

  @override
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }

  @override
  Future<String> takePicture({int jpegQuality = 85}) async {
    if (_controller == null || !isInitialized) {
      throw CameraException('not_initialized', '相机未初始化');
    }
    final file = await _controller!.takePicture();
    return file.path;
  }

  @override
  Widget buildPreview() {
    if (_controller == null || !isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Transform.flip(flipX: true, child: CameraPreview(_controller!));
  }
}
