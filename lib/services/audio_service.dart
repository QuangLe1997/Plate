import 'package:flutter/services.dart';

class AudioService {
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  Future<void> playSuccessSound() async {
    if (!_isEnabled) return;

    try {
      // Use system click sound
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Ignore audio errors
    }
  }

  Future<void> playErrorSound() async {
    if (!_isEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      // Ignore audio errors
    }
  }

  Future<void> playClickSound() async {
    if (!_isEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Ignore audio errors
    }
  }

  void dispose() {
    // No resources to dispose
  }
}
