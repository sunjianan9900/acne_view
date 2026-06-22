import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/models/treatment_type.dart';

const _prefsKey = 'custom_treatment_tags';

class CustomTreatmentTagsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefsKey) ?? [];
  }

  Future<void> addTag(String tag) async {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) return;
    if (commonTreatmentTags.contains(trimmed)) return;

    final current = state.value ?? [];
    if (current.contains(trimmed)) return;

    final updated = [...current, trimmed];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, updated);
    state = AsyncData(updated);
  }

  Future<void> removeTag(String tag) async {
    final current = state.value ?? [];
    if (!current.contains(tag)) return;

    final updated = current.where((t) => t != tag).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, updated);
    state = AsyncData(updated);
  }
}

final customTreatmentTagsProvider =
    AsyncNotifierProvider<CustomTreatmentTagsNotifier, List<String>>(
      CustomTreatmentTagsNotifier.new,
    );

final allTreatmentTagsProvider = Provider<List<String>>((ref) {
  final custom = ref.watch(customTreatmentTagsProvider).value ?? [];
  return [...commonTreatmentTags, ...custom];
});
