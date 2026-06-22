enum TreatmentType {
  medication('medication', '药物'),
  skincare('skincare', '护肤'),
  measure('measure', '措施');

  const TreatmentType(this.id, this.label);

  final String id;
  final String label;

  static TreatmentType fromId(String id) {
    return TreatmentType.values.firstWhere(
      (t) => t.id == id,
      orElse: () => TreatmentType.measure,
    );
  }
}

const List<String> commonTreatmentTags = [
  '阿达帕林',
  '过氧化苯甲酰',
  '水杨酸',
  '壬二酸',
  '维A酸',
  '保湿霜',
  '防晒',
  '清洁面膜',
  '针清',
  '热敷',
  '痘痘贴',
];
