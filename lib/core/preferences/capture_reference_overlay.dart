import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'capture_reference_overlay_scale_level';

class CaptureReferenceOverlayScaleNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getInt(_prefsKey) ?? 0).clamp(0, 2);
  }

  Future<void> cycleScale() async {
    final current = state.value ?? 0;
    final next = (current + 1) % 3;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, next);
    state = AsyncData(next);
  }
}

final captureReferenceOverlayScaleProvider =
    AsyncNotifierProvider<CaptureReferenceOverlayScaleNotifier, int>(
      CaptureReferenceOverlayScaleNotifier.new,
    );
