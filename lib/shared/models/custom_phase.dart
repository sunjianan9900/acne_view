class CustomPhase {
  const CustomPhase({
    required this.id,
    required this.label,
    required this.colorValue,
  });

  final String id;
  final String label;
  final int colorValue;

  factory CustomPhase.fromJson(Map<String, dynamic> json) {
    return CustomPhase(
      id: json['id'] as String,
      label: json['label'] as String,
      colorValue: json['colorValue'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'colorValue': colorValue,
  };
}

const customPhaseColorPalette = <int>[
  0xFF7B8CDE,
  0xFFB07CC6,
  0xFF6BB5C9,
  0xFF8BC49A,
  0xFFE8A87C,
  0xFFD4849A,
  0xFF9B8AC4,
];
