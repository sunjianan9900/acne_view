import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/camera/capture_aspect.dart';
import '../../../core/preferences/capture_reference_overlay.dart';

/// 页面右下角悬浮显示上次拍摄照片，支持点击放大对比与关闭。
class LastPhotoOverlay extends ConsumerWidget {
  const LastPhotoOverlay({
    super.key,
    required this.photoPath,
    required this.onDismiss,
  });

  final String photoPath;
  final VoidCallback onDismiss;

  static const double baseWidth = 110;
  static const double mediumWidth = 185;
  static const double largeWidth = 290;

  static double widthForScaleLevel(int level) {
    switch (level) {
      case 1:
        return mediumWidth;
      case 2:
        return largeWidth;
      default:
        return baseWidth;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!File(photoPath).existsSync()) {
      return const SizedBox.shrink();
    }

    final scaleLevel = ref.watch(captureReferenceOverlayScaleProvider).value ?? 0;
    final width = widthForScaleLevel(scaleLevel);
    final height = width / kCaptureAspectRatio;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () =>
              ref.read(captureReferenceOverlayScaleProvider.notifier).cycleScale(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: width,
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
                  File(photoPath),
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
              onTap: onDismiss,
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
    );
  }
}
