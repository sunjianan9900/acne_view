import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/camera/capture_aspect.dart';

/// 取景框右下角悬浮显示上次拍摄照片，支持点击放大对比与关闭。
class LastPhotoOverlay extends StatefulWidget {
  const LastPhotoOverlay({
    super.key,
    required this.photoPath,
    required this.onDismiss,
  });

  final String photoPath;
  final VoidCallback onDismiss;

  static const double _baseWidth = 110;
  static const double _mediumWidth = 185;
  static const double _largeWidth = 290;

  @override
  State<LastPhotoOverlay> createState() => _LastPhotoOverlayState();
}

class _LastPhotoOverlayState extends State<LastPhotoOverlay> {
  int _scaleLevel = 0;

  double get _width {
    switch (_scaleLevel) {
      case 1:
        return LastPhotoOverlay._mediumWidth;
      case 2:
        return LastPhotoOverlay._largeWidth;
      default:
        return LastPhotoOverlay._baseWidth;
    }
  }

  void _cycleScale() {
    setState(() => _scaleLevel = (_scaleLevel + 1) % 3);
  }

  @override
  Widget build(BuildContext context) {
    if (!File(widget.photoPath).existsSync()) {
      return const SizedBox.shrink();
    }

    final height = _width / kCaptureAspectRatio;

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: _cycleScale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: _width,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Transform.flip(
                    flipX: true,
                    child: Image.file(
                      File(widget.photoPath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -8,
              right: -8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onDismiss,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white54),
                    ),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
