import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/scan_result.dart';
import '../../data/repositories/history_repository.dart';
import '../../services/ocr/ocr_service.dart';
import '../../services/ocr/models/ocr_result.dart';
import '../../services/camera_service.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';
import '../../services/vehicle_owner_service.dart';

enum ScanState {
  idle,
  initializing,
  scanning,
  detected,
  error,
}

class ScanProvider extends ChangeNotifier {
  final CameraService _cameraService;
  final OcrService _ocrService;
  final AudioService _audioService;
  final HapticService _hapticService;
  final HistoryRepository _historyRepository;

  ScanState _state = ScanState.idle;
  OcrResult? _currentResult;
  String? _errorMessage;
  bool _isProcessing = false;
  double _confidenceThreshold = 0.8;
  bool _autoContinuousScan = true;

  ScanProvider({
    CameraService? cameraService,
    OcrService? ocrService,
    AudioService? audioService,
    HapticService? hapticService,
    HistoryRepository? historyRepository,
  })  : _cameraService = cameraService ?? CameraService(),
        _ocrService = ocrService ?? OcrService(),
        _audioService = audioService ?? AudioService(),
        _hapticService = hapticService ?? HapticService(),
        _historyRepository = historyRepository ?? HistoryRepository();

  // Getters
  ScanState get state => _state;
  OcrResult? get currentResult => _currentResult;
  String? get errorMessage => _errorMessage;
  bool get isProcessing => _isProcessing;
  CameraController? get cameraController => _cameraService.controller;
  bool get isCameraInitialized => _cameraService.isInitialized;
  bool get isFlashOn => _cameraService.isFlashOn;
  double get confidenceThreshold => _confidenceThreshold;
  bool get autoContinuousScan => _autoContinuousScan;

  // Setters
  void setConfidenceThreshold(double value) {
    _confidenceThreshold = value;
    notifyListeners();
  }

  void setAutoContinuousScan(bool value) {
    _autoContinuousScan = value;
    notifyListeners();
  }

  void setSoundEnabled(bool enabled) {
    _audioService.setEnabled(enabled);
  }

  void setVibrationEnabled(bool enabled) {
    _hapticService.setEnabled(enabled);
  }

  /// Update all settings at once (called from app initialization)
  void updateSettings({
    required double confidenceThreshold,
    required bool autoContinuousScan,
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) {
    bool changed = false;

    if (_confidenceThreshold != confidenceThreshold) {
      _confidenceThreshold = confidenceThreshold;
      changed = true;
    }

    if (_autoContinuousScan != autoContinuousScan) {
      _autoContinuousScan = autoContinuousScan;
      changed = true;
    }

    _audioService.setEnabled(soundEnabled);
    _hapticService.setEnabled(vibrationEnabled);

    if (changed) {
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    _state = ScanState.initializing;
    _errorMessage = null;
    notifyListeners();

    try {
      // Initialize camera
      await _cameraService.initialize();

      // Initialize OCR service
      await _ocrService.initialize();

      _state = ScanState.idle;
      notifyListeners();
    } catch (e) {
      _state = ScanState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> startScanning() async {
    if (!_cameraService.isInitialized || _state == ScanState.scanning) {
      return;
    }

    _state = ScanState.scanning;
    _currentResult = null;
    notifyListeners();

    try {
      await _cameraService.startImageStream(_processFrame);
    } catch (e) {
      _state = ScanState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Stop image stream only (detection stops but camera still active)
  Future<void> stopScanning() async {
    debugPrint('=== [ScanProvider] stopScanning() called');
    _isProcessing = false;
    await _cameraService.stopImageStream();
    _state = ScanState.idle;
    notifyListeners();
    debugPrint('=== [ScanProvider] Image stream STOPPED');
  }

  /// COMPLETELY turn off camera - dispose controller
  /// Call this when leaving scan screen
  Future<void> pauseCamera() async {
    debugPrint('=== [ScanProvider] pauseCamera() - DISPOSING CAMERA');
    _isProcessing = false;
    _state = ScanState.idle;

    // Dispose camera controller completely
    await _cameraService.pauseCamera();

    notifyListeners();
    debugPrint('=== [ScanProvider] Camera DISPOSED');
  }

  /// Resume camera after pause
  Future<void> resumeCamera() async {
    debugPrint('=== [ScanProvider] resumeCamera()');

    // Re-create camera controller
    await _cameraService.resumeCamera();

    debugPrint('=== [ScanProvider] Camera RESUMED');
    notifyListeners();
  }

  void _processFrame(CameraImage image) async {
    if (_isProcessing || _state != ScanState.scanning) {
      return;
    }

    _isProcessing = true;

    try {
      final result = await _ocrService.processFrame(image);

      if (result != null) {
        debugPrint('=== OCR RESULT: ${result.plateNumber}, confidence: ${result.confidence}');

        if (result.confidence >= _confidenceThreshold) {
          debugPrint('=== PLATE DETECTED! Stopping camera and detection stream');
          _currentResult = result;
          _state = ScanState.detected;

          // ALWAYS stop camera stream when detection succeeds
          await _cameraService.stopImageStream();
          debugPrint('=== Camera stream STOPPED');

          // Play feedback
          await _audioService.playSuccessSound();
          await _hapticService.successFeedback();

          // Save to history
          await _saveToHistory(result);

          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('=== OCR ERROR: $e');
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _saveToHistory(OcrResult result) async {
    // Fetch owner info
    final owner = await VehicleOwnerService.fetchOwnerByPlate(result.plateNumber);

    final scanResult = ScanResult(
      id: const Uuid().v4(),
      plateNumber: result.plateNumber,
      confidence: result.confidence,
      vehicleType: result.vehicleType,
      scannedAt: result.timestamp,
      boundingBox: result.boundingBox,
      ownerName: owner?.fullName,
      ownerPhone: owner?.phoneNumber,
      ownerGender: owner?.gender,
      ownerAge: owner?.age,
      ownerAddress: owner?.displayAddress,
    );

    await _historyRepository.addScanResult(scanResult);
  }

  Future<void> toggleFlash() async {
    await _cameraService.toggleFlash();
    notifyListeners();
  }

  Future<void> setZoomLevel(double zoom) async {
    await _cameraService.setZoomLevel(zoom);
  }

  Future<void> setFocusPoint(Offset point) async {
    await _cameraService.setFocusPoint(point);
    await _cameraService.setExposurePoint(point);
  }

  void resetScan() {
    _currentResult = null;
    _state = ScanState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _ocrService.dispose();
    _audioService.dispose();
    super.dispose();
  }
}
