import 'package:flutter/material.dart';

enum AcnePhase {
  swollen('swollen', '红肿期'),
  inflammatory('inflammatory', '炎症期'),
  stable('stable', '稳定期'),
  receding('receding', '消退期');

  const AcnePhase(this.id, this.label);

  final String id;
  final String label;

  static AcnePhase fromId(String id) {
    return AcnePhase.values.firstWhere(
      (p) => p.id == id,
      orElse: () => AcnePhase.swollen,
    );
  }

  static AcnePhase? fromIdOrNull(String id) {
    if (id.isEmpty) return null;
    for (final phase in AcnePhase.values) {
      if (phase.id == id) return phase;
    }
    return null;
  }
}

Color acnePhaseColor(AcnePhase phase) {
  return switch (phase) {
    AcnePhase.swollen => const Color(0xFFE96A80),
    AcnePhase.inflammatory => const Color(0xFFF0A060),
    AcnePhase.stable => const Color(0xFFE8C547),
    AcnePhase.receding => const Color(0xFF49A685),
  };
}
