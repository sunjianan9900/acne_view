enum SpotStatus {
  active('active', '活跃'),
  concluded('concluded', '收官'),
  healed('healed', '已愈合');

  const SpotStatus(this.id, this.label);

  final String id;
  final String label;

  bool get isActive => this == SpotStatus.active;

  static SpotStatus fromId(String id) {
    return SpotStatus.values.firstWhere(
      (s) => s.id == id,
      orElse: () => SpotStatus.active,
    );
  }
}
