import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/camera/camera_factory.dart';
import '../../core/camera/camera_service.dart';
import '../../core/camera/external_camera_service.dart';
import '../../core/providers/camera_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/photo_source.dart';
import '../../shared/widgets/douji_shell.dart';
import '../face_map/quick_add_spot_sheet.dart';

class LivePreviewScreen extends ConsumerStatefulWidget {
  const LivePreviewScreen({super.key});

  @override
  ConsumerState<LivePreviewScreen> createState() => _LivePreviewScreenState();
}

class _LivePreviewScreenState extends ConsumerState<LivePreviewScreen> {
  bool _initializing = true;
  String? _error;
  String? _previewPath;
  bool _capturing = false;
  CameraService? _activeCamera;

  CameraService get _camera => _activeCamera ?? ref.read(cameraServiceProvider);

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _activeCamera?.dispose();
    super.dispose();
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
      final primary = ref.read(cameraServiceProvider);
      if (primary is ExternalCameraService && _activeCamera == null) {
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
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _initializing = false;
          _error = e.toString();
        });
      }
    }
  }

  bool get _canCapture => _error == null && !_initializing && !_capturing;

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.space) {
      return KeyEventResult.ignored;
    }
    if (!_canCapture) return KeyEventResult.ignored;
    _capture();
    return KeyEventResult.handled;
  }

  Future<void> _capture() async {
    if (_capturing) return;
    setState(() => _capturing = true);
    try {
      final path = await _camera.takePicture();
      if (!mounted) return;
      setState(() => _previewPath = path);
      await showDialog<String?>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => QuickAddSpotSheet(
          photoPath: path,
          initialRegion: null,
          photoSource: _camera.currentDevice?.isExternal == true
              ? PhotoSource.external
              : PhotoSource.builtin,
        ),
      );
      if (mounted) {
        setState(() => _previewPath = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拍照失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final camera = _camera;
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: DoujiShell(
      title: '实时预览',
      subtitle: '实时显示摄像头画面，按空格键拍照后快速新增痘痘',
      actions: [
        FilledButton.icon(
          onPressed: _initializing || _error != null || _capturing
              ? null
              : _capture,
          icon: const Icon(Icons.camera_alt_outlined),
          label: Text(_capturing ? '拍照中…' : '拍照'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.panelBorder),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed: _initCamera,
                                child: const Text('重试'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _initializing
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : camera.buildPreview(),
              ),
            ),
          ),
          if (_previewPath != null) ...[
            const SizedBox(height: 12),
            Text(
              '已拍摄，正在准备新增痘痘…',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ],
      ),
      ),
    );
  }
}
