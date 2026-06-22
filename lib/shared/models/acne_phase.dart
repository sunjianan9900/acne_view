import 'package:flutter/material.dart';

import 'custom_phase.dart';

class PhaseInfo {
  const PhaseInfo({
    required this.id,
    required this.label,
    required this.color,
    this.isCustom = false,
    this.builtinPhase,
  });

  final String id;
  final String label;
  final Color color;
  final bool isCustom;
  final AcnePhase? builtinPhase;
}

List<PhaseInfo> buildAllPhases({
  required Map<String, String> customLabels,
  required List<CustomPhase> customPhases,
}) {
  final builtIn = AcnePhase.values.map(
    (phase) => PhaseInfo(
      id: phase.id,
      label: customLabels[phase.id] ?? phase.label,
      color: acnePhaseColor(phase),
      builtinPhase: phase,
    ),
  );
  final custom = customPhases.map(
    (phase) => PhaseInfo(
      id: phase.id,
      label: phase.label,
      color: Color(phase.colorValue),
      isCustom: true,
    ),
  );
  return [...builtIn, ...custom];
}

PhaseInfo? findPhaseInfo(String id, List<PhaseInfo> phases) {
  if (id.isEmpty) return null;
  for (final phase in phases) {
    if (phase.id == id) return phase;
  }
  return null;
}

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
