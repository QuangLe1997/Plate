import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

class HapticService {
  bool _isEnabled = true;
  bool? _hasVibrator;

  bool get isEnabled => _isEnabled;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    debugPrint('=== [HapticService] Vibration enabled: $enabled');
  }

  /// Check if device has vibrator
  Future<bool> _checkVibrator() async {
    _hasVibrator ??= await Vibration.hasVibrator() ?? false;
    return _hasVibrator!;
  }

  Future<void> lightImpact() async {
    if (!_isEnabled) return;
    if (!await _checkVibrator()) return;
    await Vibration.vibrate(duration: 50);
  }

  Future<void> mediumImpact() async {
    if (!_isEnabled) return;
    if (!await _checkVibrator()) return;
    await Vibration.vibrate(duration: 100);
  }

  Future<void> heavyImpact() async {
    if (!_isEnabled) return;
    if (!await _checkVibrator()) return;
    await Vibration.vibrate(duration: 200);
  }

  Future<void> selectionClick() async {
    if (!_isEnabled) return;
    if (!await _checkVibrator()) return;
    await Vibration.vibrate(duration: 30);
  }

  Future<void> vibrate({int duration = 500}) async {
    if (!_isEnabled) return;
    if (!await _checkVibrator()) return;
    await Vibration.vibrate(duration: duration);
  }

  /// Play success feedback - vibrate for 300ms
  Future<void> successFeedback() async {
    if (!_isEnabled) {
      debugPrint('=== [HapticService] Vibration disabled, skipping');
      return;
    }

    final hasVibrator = await _checkVibrator();
    debugPrint('=== [HapticService] Has vibrator: $hasVibrator');

    if (!hasVibrator) {
      debugPrint('=== [HapticService] No vibrator available');
      return;
    }

    debugPrint('=== [HapticService] Playing success vibration (300ms)...');
    await Vibration.vibrate(duration: 300);
    debugPrint('=== [HapticService] Vibration triggered');
  }

  /// Play error feedback (two short vibrations)
  Future<void> errorFeedback() async {
    if (!_isEnabled) return;
    if (!await _checkVibrator()) return;

    // Pattern: vibrate, pause, vibrate
    await Vibration.vibrate(pattern: [0, 200, 100, 200]);
  }
}
