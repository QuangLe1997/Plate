import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HapticService {
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    debugPrint('=== [HapticService] Vibration enabled: $enabled');
  }

  Future<void> lightImpact() async {
    if (!_isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> mediumImpact() async {
    if (!_isEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> heavyImpact() async {
    if (!_isEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> selectionClick() async {
    if (!_isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  Future<void> vibrate() async {
    if (!_isEnabled) return;
    await HapticFeedback.vibrate();
  }

  /// Play success feedback - use vibrate() for better Android compatibility
  Future<void> successFeedback() async {
    if (!_isEnabled) {
      debugPrint('=== [HapticService] Vibration disabled, skipping');
      return;
    }
    debugPrint('=== [HapticService] Playing success vibration...');
    // Use vibrate() for better compatibility on Android devices
    // mediumImpact() doesn't work on all Android devices
    await HapticFeedback.vibrate();
    debugPrint('=== [HapticService] Vibration triggered');
  }

  /// Play error feedback (heavy impact followed by light)
  Future<void> errorFeedback() async {
    if (!_isEnabled) return;
    await HapticFeedback.vibrate();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.vibrate();
  }
}
