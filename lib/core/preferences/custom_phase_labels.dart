import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/models/acne_phase.dart';

const _prefsKey = 'custom_phase_labels';

class CustomPhaseLabelsNotifier extends AsyncNotifier<Map<String, String>> {
  @override
  Future<Map<String, String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value as String));
    } catch (_) {
      return {};
    }
  }

  Future<void> setLabel(String phaseId, String label) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;

    final current = Map<String, String>.from(state.value ?? {});
    current[phaseId] = trimmed;
    await _persist(current);
  }

  Future<void> resetLabel(String phaseId) async {
    final current = Map<String, String>.from(state.value ?? {});
    if (!current.containsKey(phaseId)) return;

    current.remove(phaseId);
    await _persist(current);
  }

  Future<void> _persist(Map<String, String> labels) async {
    final prefs = await SharedPreferences.getInstance();
    if (labels.isEmpty) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, jsonEncode(labels));
    }
    state = AsyncData(labels);
  }
}

final customPhaseLabelsProvider =
    AsyncNotifierProvider<CustomPhaseLabelsNotifier, Map<String, String>>(
      CustomPhaseLabelsNotifier.new,
    );

final phaseLabelsProvider = Provider<Map<String, String>>((ref) {
  return ref.watch(customPhaseLabelsProvider).value ?? {};
});

String phaseDisplayLabel(AcnePhase phase, Map<String, String> customLabels) {
  return customLabels[phase.id] ?? phase.label;
}
