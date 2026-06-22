import 'dart:ui';

import 'package:acne_view/shared/face_map/face_map_coordinates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalized marker position is stable across canvas sizes', () {
    const nx = 0.42;
    const ny = 0.58;

    const preview = Size(260, 130);
    const editor = Size(520, 560);

    for (final size in [preview, editor, const Size(300, 300)]) {
      final image = FaceMapCoordinates.imageRect(size);
      final local = FaceMapCoordinates.localFromNormalized(nx, ny, size);
      final roundTrip = FaceMapCoordinates.normalizedFromLocal(local, size);

      expect(roundTrip, isNotNull);
      expect(roundTrip!.dx, closeTo(nx, 0.0001));
      expect(roundTrip.dy, closeTo(ny, 0.0001));

      final relativeX = (local.dx - image.left) / image.width;
      final relativeY = (local.dy - image.top) / image.height;
      expect(relativeX, closeTo(nx, 0.0001));
      expect(relativeY, closeTo(ny, 0.0001));
    }

    final previewImage = FaceMapCoordinates.imageRect(preview);
    final editorImage = FaceMapCoordinates.imageRect(editor);
    final previewLocal = FaceMapCoordinates.localFromNormalized(nx, ny, preview);
    final editorLocal = FaceMapCoordinates.localFromNormalized(nx, ny, editor);

    final previewRatio = Offset(
      (previewLocal.dx - previewImage.left) / previewImage.width,
      (previewLocal.dy - previewImage.top) / previewImage.height,
    );
    final editorRatio = Offset(
      (editorLocal.dx - editorImage.left) / editorImage.width,
      (editorLocal.dy - editorImage.top) / editorImage.height,
    );

    expect(previewRatio.dx, closeTo(editorRatio.dx, 0.0001));
    expect(previewRatio.dy, closeTo(editorRatio.dy, 0.0001));
  });

  test('marker radius scales with rendered image size', () {
    final small = FaceMapCoordinates.markerRadius(const Size(260, 130));
    final large = FaceMapCoordinates.markerRadius(const Size(520, 560));
    expect(large, greaterThan(small));
  });
}
