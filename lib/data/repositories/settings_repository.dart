import '../datasources/preferences.dart';
import '../models/settings.dart';

class SettingsRepository {
  // Get current settings
  AppSettings getSettings() {
    return PreferencesService.getSettings();
  }

  // Save settings
  Future<void> saveSettings(AppSettings settings) async {
    await PreferencesService.saveSettings(settings);
  }

  // Update confidence threshold
  Future<void> updateConfidenceThreshold(double value) async {
    await PreferencesService.setConfidenceThreshold(value);
  }

  // Update auto continuous scan
  Future<void> updateAutoContinuousScan(bool value) async {
    await PreferencesService.setAutoContinuousScan(value);
  }

  // Update sound enabled
  Future<void> updateSoundEnabled(bool value) async {
    await PreferencesService.setSoundEnabled(value);
  }

  // Update vibration enabled
  Future<void> updateVibrationEnabled(bool value) async {
    await PreferencesService.setVibrationEnabled(value);
  }

  // Update startup delay
  Future<void> updateStartupDelayMs(int value) async {
    await PreferencesService.setStartupDelayMs(value);
  }

  // Update confirmation frames
  Future<void> updateConfirmationFrames(int value) async {
    await PreferencesService.setConfirmationFrames(value);
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    await PreferencesService.saveSettings(AppSettings.defaults());
  }

  // Check if first launch
  bool isFirstLaunch() {
    return PreferencesService.isFirstLaunch();
  }

  // Mark first launch complete
  Future<void> markFirstLaunchComplete() async {
    await PreferencesService.setFirstLaunch(false);
  }
}
