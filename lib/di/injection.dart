import '../data/repositories/history_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../services/ocr/ocr_service.dart';
import '../services/camera_service.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Repositories
  final HistoryRepository historyRepository = HistoryRepository();
  final SettingsRepository settingsRepository = SettingsRepository();

  // Services
  CameraService? _cameraService;
  OcrService? _ocrService;
  AudioService? _audioService;
  HapticService? _hapticService;

  CameraService get cameraService {
    _cameraService ??= CameraService();
    return _cameraService!;
  }

  OcrService get ocrService {
    _ocrService ??= OcrService();
    return _ocrService!;
  }

  AudioService get audioService {
    _audioService ??= AudioService();
    return _audioService!;
  }

  HapticService get hapticService {
    _hapticService ??= HapticService();
    return _hapticService!;
  }

  void dispose() {
    _cameraService?.dispose();
    _ocrService?.dispose();
    _audioService?.dispose();
    _cameraService = null;
    _ocrService = null;
    _audioService = null;
    _hapticService = null;
  }
}

// Global instance
final sl = ServiceLocator();
