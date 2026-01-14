import 'package:flutter/foundation.dart';

import '../../data/models/settings.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;

  AppSettings _settings = AppSettings.defaults();
  bool _isLoading = false;

  SettingsProvider({SettingsRepository? repository})
      : _repository = repository ?? SettingsRepository();

  // Getters
  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  double get confidenceThreshold => _settings.confidenceThreshold;
  bool get autoContinuousScan => _settings.autoContinuousScan;
  bool get soundEnabled => _settings.soundEnabled;
  bool get vibrationEnabled => _settings.vibrationEnabled;
  int get confidenceThresholdPercent => _settings.confidenceThresholdPercent;
  int get startupDelayMs => _settings.startupDelayMs;
  int get confirmationFrames => _settings.confirmationFrames;
  double get startupDelaySeconds => _settings.startupDelaySeconds;

  void loadSettings() {
    _settings = _repository.getSettings();
    notifyListeners();
  }

  Future<void> setConfidenceThreshold(double value) async {
    _settings = _settings.copyWith(confidenceThreshold: value);
    await _repository.updateConfidenceThreshold(value);
    notifyListeners();
  }

  Future<void> setAutoContinuousScan(bool value) async {
    _settings = _settings.copyWith(autoContinuousScan: value);
    await _repository.updateAutoContinuousScan(value);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _settings = _settings.copyWith(soundEnabled: value);
    await _repository.updateSoundEnabled(value);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _settings = _settings.copyWith(vibrationEnabled: value);
    await _repository.updateVibrationEnabled(value);
    notifyListeners();
  }

  Future<void> setStartupDelayMs(int value) async {
    _settings = _settings.copyWith(startupDelayMs: value);
    await _repository.updateStartupDelayMs(value);
    notifyListeners();
  }

  Future<void> setConfirmationFrames(int value) async {
    _settings = _settings.copyWith(confirmationFrames: value);
    await _repository.updateConfirmationFrames(value);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    await _repository.resetToDefaults();
    _settings = AppSettings.defaults();
    notifyListeners();
  }

  bool isFirstLaunch() {
    return _repository.isFirstLaunch();
  }

  Future<void> markFirstLaunchComplete() async {
    await _repository.markFirstLaunchComplete();
  }
}
