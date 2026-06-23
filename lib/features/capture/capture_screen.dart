import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/camera/camera_factory.dart';
import '../../core/camera/camera_service.dart';
import '../../core/camera/external_camera_service.dart';
import '../../core/providers/camera_provider.dart';
import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/photo/add_photo_flow.dart';
import '../../shared/widgets/camera_device_dropdown.dart';
import 'widgets/capture_viewport.dart';
import 'widgets/last_photo_overlay.dart';

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
  bool _referencePhotoDismissed = false;
  CameraService? _activeCamera;
  List<CameraDeviceInfo> _devices = [];

  CameraService get _camera => _activeCamera ?? ref.read(cameraServiceProvider);

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
      final devices = await camera.listDevices();
      if (mounted) {
        setState(() {
          _initializing = false;
          _activeCamera = camera;
          _devices = devices;
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
          final devices = await fallback.listDevices();
          if (mounted) {
            setState(() {
              _initializing = false;
              _activeCamera = fallback;
              _devices = devices;
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('拍照失败: $e')));
      }
    }
  }

  Future<void> _selectDevice(String deviceId) async {
    if (deviceId == _camera.currentDevice?.id) return;
    setState(() => _initializing = true);
    try {
      await _camera.selectDevice(deviceId);
      final devices = await _camera.listDevices();
      if (mounted) {
        setState(() {
          _devices = devices;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = _friendlyCameraError(e));
      }
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  void _confirmPhoto() {
    if (_capturedPath == null) return;
    final isExternal = _camera.currentDevice?.isExternal == true;
    context.push(
      '/check-in',
      extra: {
        'spotId': widget.spotId,
        'photoPath': _capturedPath,
        'isExternalCamera': isExternal,
      },
    );
  }

  bool get _canTakePicture =>
      _error == null && !_initializing && _capturedPath == null;

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.space) {
      return KeyEventResult.ignored;
    }
    if (!_canTakePicture) return KeyEventResult.ignored;
    _takePicture();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final camera = _camera;

    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
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
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white54,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '相机初始化失败',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white54,
                          height: 1.4,
                        ),
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
      ),
    );
  }

  Widget _buildCamera(CameraService camera) {
    final latestPhoto = ref.watch(spotThumbnailProvider(widget.spotId));
    final referencePath = latestPhoto.maybeWhen(
      data: (photo) => photo?.filePath,
      orElse: () => null,
    );
    final showReferenceOverlay =
        !_referencePhotoDismissed && referencePath != null;

    return Column(
      children: [
        CaptureViewport(
          loading: _initializing,
          child: _initializing
              ? const SizedBox.shrink()
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    CapturePreviewFrame(camera: camera),
                    if (showReferenceOverlay)
                      LastPhotoOverlay(
                        photoPath: referencePath,
                        onDismiss: () =>
                            setState(() => _referencePhotoDismissed = true),
                      ),
                  ],
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: _initializing
                        ? null
                        : () => pickImageAndCheckIn(context, widget.spotId),
                    icon: const Icon(Icons.photo_library_outlined),
                    color: Colors.white,
                    iconSize: 32,
                    tooltip: '从相册选择',
                  ),
                ),
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
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _devices.isNotEmpty
                      ? CameraDeviceDropdown(
                          devices: _devices,
                          selectedId: camera.currentDevice?.id,
                          enabled: !_initializing,
                          darkStyle: true,
                          width: 260,
                          compact: true,
                          onChanged: _selectDevice,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        CaptureViewport(
          child: SizedBox.expand(
            child: Image.file(File(_capturedPath!), fit: BoxFit.cover),
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
