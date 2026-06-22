import 'dart:io';

import 'package:flutter/foundation.dart';

import 'builtin_camera_service.dart';
import 'camera_service.dart';
import 'external_camera_service.dart';
import 'uvc_camera_client.dart';

/// 根据平台自动选择相机实现：
/// - iOS 模拟器 → BuiltinCameraService
/// - macOS → ExternalCameraService（优先 USB 外置摄像头）
/// - 真机 iPad + 已连接外接 UVC → ExternalCameraService
/// - 其他（iPhone / iPad 无外接 / Android 等）→ BuiltinCameraService
Future<CameraService> createCameraService() async {
  if (!kIsWeb && Platform.isMacOS) {
    final supported = await UvcCamera.isSupported;
    if (supported) {
      return ExternalCameraService();
    }
  }

  if (!kIsWeb && Platform.isIOS) {
    final isSimulator = await UvcCamera.isSimulator;
    if (isSimulator) {
      return BuiltinCameraService();
    }

    final supported = await UvcCamera.isSupported;
    if (supported) {
      final hasExternal = await UvcCamera.hasExternalCamera();
      if (hasExternal) {
        return ExternalCameraService();
      }
    }
  }
  return BuiltinCameraService();
}

/// 外接相机初始化失败时，回退到内置相机（iOS 真机调试兜底；macOS 无内置 camera 插件）
Future<CameraService> createFallbackCameraService(CameraService current) async {
  await current.dispose();
  if (!kIsWeb && Platform.isMacOS) {
    throw UnsupportedError('macOS 仅支持 UVC 相机插件，无法回退到内置相机');
  }
  return BuiltinCameraService();
}
