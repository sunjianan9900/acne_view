enum PhotoSource {
  builtin('builtin', '内置摄像头'),
  external('external', '外接摄像头');

  const PhotoSource(this.id, this.label);

  final String id;
  final String label;

  static PhotoSource fromId(String id) {
    return PhotoSource.values.firstWhere(
      (s) => s.id == id,
      orElse: () => PhotoSource.builtin,
    );
  }
}
