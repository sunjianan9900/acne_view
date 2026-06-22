/// 面部标记痘痘大小档位。
enum FaceMarkerSize {
  large('large', '大痘', 0.022),
  medium('medium', '中痘', 0.015),
  small('small', '小痘', 0.010);

  const FaceMarkerSize(this.id, this.label, this.scaleFactor);

  final String id;
  final String label;
  final double scaleFactor;

  static FaceMarkerSize fromId(String? id) {
    for (final size in FaceMarkerSize.values) {
      if (size.id == id) return size;
    }
    return FaceMarkerSize.large;
  }
}
