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

/// 将已废弃的内置时期 id 映射到当前时期，保证历史打卡数据仍可展示。
String normalizePhaseId(String id) {
  return switch (id) {
    'stable' => AcnePhase.repairing.id,
    _ => id,
  };
}

PhaseInfo? findPhaseInfo(String id, List<PhaseInfo> phases) {
  if (id.isEmpty) return null;
  final normalizedId = normalizePhaseId(id);
  for (final phase in phases) {
    if (phase.id == normalizedId) return phase;
  }
  return null;
}

enum AcnePhase {
  mildComedone('mild_comedone', '轻微粉刺期'),
  closedComedone('closed_comedone', '闭口粉刺期'),
  inflammatory('inflammatory', '炎症期'),
  swollen('swollen', '红肿期'),
  pustule('pustule', '脓包期'),
  broken('broken', '破损期'),
  receding('receding', '消退期'),
  repairing('repairing', '修复期');

  const AcnePhase(this.id, this.label);

  final String id;
  final String label;

  static AcnePhase fromId(String id) {
    final normalizedId = normalizePhaseId(id);
    return AcnePhase.values.firstWhere(
      (p) => p.id == normalizedId,
      orElse: () => AcnePhase.mildComedone,
    );
  }

  static AcnePhase? fromIdOrNull(String id) {
    if (id.isEmpty) return null;
    final normalizedId = normalizePhaseId(id);
    for (final phase in AcnePhase.values) {
      if (phase.id == normalizedId) return phase;
    }
    return null;
  }
}

Color acnePhaseColor(AcnePhase phase) {
  return switch (phase) {
    AcnePhase.mildComedone => const Color(0xFFF5E6A8),
    AcnePhase.closedComedone => const Color(0xFFE8C547),
    AcnePhase.inflammatory => const Color(0xFFF0A060),
    AcnePhase.swollen => const Color(0xFFE96A80),
    AcnePhase.pustule => const Color(0xFFD94F6A),
    AcnePhase.broken => const Color(0xFFB84D6F),
    AcnePhase.receding => const Color(0xFF49A685),
    AcnePhase.repairing => const Color(0xFF6BBF8A),
  };
}
