enum FaceRegion {
  forehead('forehead', '额头'),
  leftCheek('left_cheek', '左颊'),
  rightCheek('right_cheek', '右颊'),
  nose('nose', '鼻翼'),
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
