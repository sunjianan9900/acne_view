enum FaceRegion {
  forehead('forehead', '额头'),
  leftEye('left_eye', '左眼周'),
  rightEye('right_eye', '右眼周'),
  leftCheek('left_cheek', '左颊'),
  rightCheek('right_cheek', '右颊'),
  nose('nose', '鼻翼'),
  upperLip('upper_lip', '上唇'),
  mouthCorner('mouth_corner', '嘴角'),
  chin('chin', '下巴'),
  jawline('jawline', '下颌');

  const FaceRegion(this.id, this.label);

  final String id;
  final String label;

  static FaceRegion? fromId(String id) {
    for (final region in FaceRegion.values) {
      if (region.id == id) return region;
    }
    return null;
  }
}
