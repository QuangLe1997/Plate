import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings.dart';

class PreferencesService {
  static const String _settingsKey = 'app_settings';
  static const String _firstLaunchKey = 'first_launch';
  static const String _lastScanKey = 'last_scan_plate';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception('PreferencesService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Settings
  static Future<void> saveSettings(AppSettings settings) async {
    await _preferences.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  static AppSettings getSettings() {
    final json = _preferences.getString(_settingsKey);
    if (json == null) return AppSettings.defaults();

    try {
      return AppSettings.fromJson(jsonDecode(json));
    } catch (e) {
      return AppSettings.defaults();
    }
  }

  // Confidence threshold
  static Future<void> setConfidenceThreshold(double value) async {
    final settings = getSettings().copyWith(confidenceThreshold: value);
    await saveSettings(settings);
  }

  static double getConfidenceThreshold() {
    return getSettings().confidenceThreshold;
  }

  // Auto continuous scan
  static Future<void> setAutoContinuousScan(bool value) async {
    final settings = getSettings().copyWith(autoContinuousScan: value);
    await saveSettings(settings);
  }

  static bool getAutoContinuousScan() {
    return getSettings().autoContinuousScan;
  }

  // Sound enabled
  static Future<void> setSoundEnabled(bool value) async {
    final settings = getSettings().copyWith(soundEnabled: value);
    await saveSettings(settings);
  }

  static bool getSoundEnabled() {
    return getSettings().soundEnabled;
  }

  // Vibration enabled
  static Future<void> setVibrationEnabled(bool value) async {
    final settings = getSettings().copyWith(vibrationEnabled: value);
    await saveSettings(settings);
  }

  static bool getVibrationEnabled() {
    return getSettings().vibrationEnabled;
  }

  // Startup delay
  static Future<void> setStartupDelayMs(int value) async {
    final settings = getSettings().copyWith(startupDelayMs: value);
    await saveSettings(settings);
  }

  static int getStartupDelayMs() {
    return getSettings().startupDelayMs;
  }

  // Confirmation frames
  static Future<void> setConfirmationFrames(int value) async {
    final settings = getSettings().copyWith(confirmationFrames: value);
    await saveSettings(settings);
  }

  static int getConfirmationFrames() {
    return getSettings().confirmationFrames;
  }

  // First launch
  static Future<void> setFirstLaunch(bool value) async {
    await _preferences.setBool(_firstLaunchKey, value);
  }

  static bool isFirstLaunch() {
    return _preferences.getBool(_firstLaunchKey) ?? true;
  }

  // Last scan plate (for quick access)
  static Future<void> setLastScanPlate(String plate) async {
    await _preferences.setString(_lastScanKey, plate);
  }

  static String? getLastScanPlate() {
    return _preferences.getString(_lastScanKey);
  }

  // Clear all
  static Future<void> clear() async {
    await _preferences.clear();
  }
}
