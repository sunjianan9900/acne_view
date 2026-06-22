import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../shared/models/acne_phase.dart';
import '../../shared/models/custom_phase.dart';
import 'custom_phase_labels.dart';

const _prefsKey = 'custom_phases';
const _uuid = Uuid();

class CustomPhasesNotifier extends AsyncNotifier<List<CustomPhase>> {
  @override
  Future<List<CustomPhase>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => CustomPhase.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addPhase(String label) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;

    final current = state.value ?? [];
    final customLabels = ref.read(phaseLabelsProvider);
    final existingLabels = {
      for (final phase in AcnePhase.values)
        phaseDisplayLabel(phase, customLabels).toLowerCase(),
      for (final phase in current) phase.label.toLowerCase(),
    };
    if (existingLabels.contains(trimmed.toLowerCase())) return;

    final colorValue =
        customPhaseColorPalette[current.length % customPhaseColorPalette.length];
    final phase = CustomPhase(
      id: 'custom_${_uuid.v4()}',
      label: trimmed,
      colorValue: colorValue,
    );

    final updated = [...current, phase];
    await _persist(updated);
  }

  Future<void> removePhase(String phaseId) async {
    final current = state.value ?? [];
    if (!current.any((phase) => phase.id == phaseId)) return;

    final updated = current.where((phase) => phase.id != phaseId).toList();
    await _persist(updated);
  }

  Future<void> _persist(List<CustomPhase> phases) async {
    final prefs = await SharedPreferences.getInstance();
    if (phases.isEmpty) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(
        _prefsKey,
        jsonEncode(phases.map((phase) => phase.toJson()).toList()),
      );
    }
    state = AsyncData(phases);
  }
}

final customPhasesProvider =
    AsyncNotifierProvider<CustomPhasesNotifier, List<CustomPhase>>(
      CustomPhasesNotifier.new,
    );

final allPhasesProvider = Provider<List<PhaseInfo>>((ref) {
  final customLabels = ref.watch(phaseLabelsProvider);
  final customPhases = ref.watch(customPhasesProvider).value ?? [];
  return buildAllPhases(
    customLabels: customLabels,
    customPhases: customPhases,
  );
});
