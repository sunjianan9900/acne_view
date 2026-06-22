import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/camera/builtin_camera_service.dart';
import '../../core/camera/camera_factory.dart';
import '../../core/camera/camera_service.dart';
import '../../core/camera/external_camera_service.dart';
import '../../core/providers/camera_provider.dart';
import '../../core/theme/app_theme.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key, required this.spotId});

  final String spotId;

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  bool _initializing = true;
  String? _error;
  String? _capturedPath;
  CameraService? _activeCamera;

  CameraService get _camera =>
      _activeCamera ?? ref.read(cameraServiceProvider);

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    setState(() {
      _initializing = true;
      _error = null;
    });

    try {
      final camera = _camera;
      await camera.initialize();
      if (mounted) {
        setState(() {
          _initializing = false;
          _activeCamera = camera;
        });
      }
    } catch (e) {
      // 外接相机失败时自动回退内置相机（macOS 无内置 camera 插件，跳过）
      final primary = ref.read(cameraServiceProvider);
      if (primary is ExternalCameraService &&
          _activeCamera == null &&
          !Platform.isMacOS) {
        try {
          final fallback = await createFallbackCameraService(primary);
          await fallback.initialize();
          if (mounted) {
            setState(() {
              _initializing = false;
              _activeCamera = fallback;
              _error = null;
            });
          }
          return;
        } catch (_) {
          // 继续展示下方友好错误
        }
      }

      if (mounted) {
        setState(() {
          _initializing = false;
          _error = _friendlyCameraError(e);
        });
      }
    }
  }

  String _friendlyCameraError(Object e) {
    final msg = e.toString();
    if (msg.contains('未找到可用摄像头') || msg.contains('no_camera')) {
      if (Platform.isMacOS) {
        return '未检测到可用摄像头。\n\n'
            '• 请连接 USB 外置摄像头（App 会优先使用外接设备）。\n'
            '• 若无外接摄像头，将使用 Mac 内置 FaceTime 摄像头。\n'
            '• 请在「系统设置 → 隐私与安全性 → 相机」中允许痘迹访问相机。';
      }
      return '未检测到可用摄像头。\n\n'
          '• iOS 模拟器无法使用 Mac 上外接的 USB 摄像头，请改用真机 iPad 连接 WTM-W1-1，'
          '或在模拟器中使用 Mac 内置摄像头（本 App 已自动切换为内置相机模式）。\n'
          '• 若在真机上，请确认已在「设置」中授予相机权限。';
    }
    if (msg.contains('CameraAccessDenied') || msg.contains('permission')) {
      return '相机权限被拒绝，请在「设置 → 痘迹」中开启相机权限。';
    }
    return '相机初始化失败：$msg';
  }

  Future<void> _takePicture() async {
    try {
      final path = await _camera.takePicture();
      if (mounted) setState(() => _capturedPath = path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拍照失败: $e')),
        );
      }
    }
  }

  Future<void> _switchCamera() async {
    final camera = _camera;
    setState(() => _initializing = true);
    try {
      if (camera is BuiltinCameraService) {
        await camera.switchCamera();
      } else if (camera is ExternalCameraService) {
        await camera.switchCamera();
        await camera.initialize();
      }
    } catch (e) {
      _error = _friendlyCameraError(e);
    }
    if (mounted) setState(() => _initializing = false);
  }

  void _confirmPhoto() {
    if (_capturedPath == null) return;
    final isExternal = _camera.currentDevice?.isExternal == true;
    context.push('/check-in', extra: {
      'spotId': widget.spotId,
      'photoPath': _capturedPath,
      'isExternalCamera': isExternal,
    });
  }

  @override
  Widget build(BuildContext context) {
    final camera = _camera;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('拍摄痘痘'),
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white54, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      '相机初始化失败',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _error = null;
                          _initializing = true;
                        });
                        _initCamera();
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            )
          : _capturedPath != null
              ? _buildPreview()
              : _buildCamera(camera),
    );
  }

  Widget _buildCamera(dynamic camera) {
    return Column(
      children: [
        Expanded(
          child: _initializing
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: camera.buildPreview(),
                ),
        ),
        if (camera.currentDevice != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (camera.hasExternalCamera)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '外接',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                Text(
                  camera.currentDevice!.name,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: _initializing ? null : _switchCamera,
                icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                iconSize: 32,
              ),
              GestureDetector(
                onTap: _initializing ? null : _takePicture,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_capturedPath!),
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _capturedPath = null),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  child: const Text('重拍'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _confirmPhoto,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                  ),
                  child: const Text('确认并记录'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
