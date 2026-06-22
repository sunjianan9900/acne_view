import 'dart:ui';

import '../models/face_marker_size.dart';

/// 面部地图归一化坐标：相对 `BoxFit.contain` 渲染后的图片区域 (0–1)。
class FaceMapCoordinates {
  FaceMapCoordinates._();

  static const Size faceOutlineSize = Size(1448, 1086);
  static const Rect faceContentFrame = Rect.fromLTWH(0.274, 0.022, 0.451, 0.924);

  static Rect imageRect(Size canvasSize) {
    if (canvasSize.isEmpty) return Rect.zero;

    final imageAspect = faceOutlineSize.width / faceOutlineSize.height;
    final canvasAspect = canvasSize.width / canvasSize.height;

    late final double width;
    late final double height;
    if (canvasAspect > imageAspect) {
      height = canvasSize.height;
      width = height * imageAspect;
    } else {
      width = canvasSize.width;
      height = width / imageAspect;
    }

    return Rect.fromLTWH(
      (canvasSize.width - width) / 2,
      (canvasSize.height - height) / 2,
      width,
      height,
    );
  }

  static Rect legacyContentRect(Size size) {
    return Rect.fromLTWH(
      size.width * faceContentFrame.left,
      size.height * faceContentFrame.top,
      size.width * faceContentFrame.width,
      size.height * faceContentFrame.height,
    );
  }

  static Offset localFromNormalized(double nx, double ny, Size size) {
    final image = imageRect(size);
    return Offset(
      image.left + nx.clamp(0.0, 1.0) * image.width,
      image.top + ny.clamp(0.0, 1.0) * image.height,
    );
  }

  static Offset? normalizedFromLocal(Offset local, Size size) {
    final image = imageRect(size);
    if (!image.contains(local)) return null;
    return Offset(
      (local.dx - image.left) / image.width,
      (local.dy - image.top) / image.height,
    );
  }

  static Offset migrateLegacyNormalized(double nx, double ny) {
    const ref = Size(520, 560);
    final legacy = legacyContentRect(ref);
    final local = Offset(
      legacy.left + nx * legacy.width,
      legacy.top + ny * legacy.height,
    );
    return normalizedFromLocal(local, ref) ?? Offset(nx, ny);
  }

  static double markerRadius(
    Size canvasSize, {
    FaceMarkerSize markerSize = FaceMarkerSize.small,
    bool selected = false,
    bool dragging = false,
  }) {
    final image = imageRect(canvasSize);
    final base = image.shortestSide * markerSize.scaleFactor;
    final scale = selected || dragging ? 1.12 : 1.0;
    return (base * scale).clamp(2.0, 14.0);
  }

  static double markerHitRadius(
    Size canvasSize, {
    FaceMarkerSize markerSize = FaceMarkerSize.small,
  }) {
    final visual = markerRadius(canvasSize, markerSize: markerSize);
    return (visual * 2.2).clamp(10.0, 22.0);
  }

  static Offset markerRecordPosition(double mapX, double mapY, Size size) =>
      localFromNormalized(mapX, mapY, size);
}
