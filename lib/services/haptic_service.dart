import 'package:flutter/services.dart';

class HapticService {
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
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

  /// Play success feedback (medium impact)
  Future<void> successFeedback() async {
    await mediumImpact();
  }

  /// Play error feedback (heavy impact followed by light)
  Future<void> errorFeedback() async {
    await heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await lightImpact();
  }
}
