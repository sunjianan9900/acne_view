import 'package:flutter/material.dart';

import '../../../core/camera/camera_service.dart';
import '../../../core/camera/capture_aspect.dart';

/// 按 2568:1712 比例展示拍摄/预览区域，随窗口缩放而等比变化。
class CaptureViewport extends StatelessWidget {
  const CaptureViewport({super.key, required this.child, this.loading = false});

  final Widget child;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Center(
          child: AspectRatio(
            aspectRatio: kCaptureAspectRatio,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 在取景框内以 cover 方式铺满摄像头画面。
class CapturePreviewFrame extends StatelessWidget {
  const CapturePreviewFrame({super.key, required this.camera});

  final CameraService camera;

  @override
  Widget build(BuildContext context) {
    final sourceAspect = camera.previewAspectRatio ?? kCaptureAspectRatio;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportW = constraints.maxWidth;
        final viewportH = constraints.maxHeight;
        final viewportAspect = viewportW / viewportH;

        final double childW;
        final double childH;
        if (sourceAspect > viewportAspect) {
          childH = viewportH;
          childW = viewportH * sourceAspect;
        } else {
          childW = viewportW;
          childH = viewportW / sourceAspect;
        }

        return ClipRect(
          child: Center(
            child: SizedBox(
              width: childW,
              height: childH,
              child: camera.buildPreview(),
            ),
          ),
        );
      },
    );
  }
}
