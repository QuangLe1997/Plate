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

  Future<void> stopScanning() async {
    await _cameraService.stopImageStream();
    _state = ScanState.idle;
    _isProcessing = false;
    notifyListeners();
  }

  void _processFrame(CameraImage image) async {
    if (_isProcessing || _state != ScanState.scanning) {
      return;
    }

    _isProcessing = true;

    try {
      final result = await _ocrService.processFrame(image);

      if (result != null && result.confidence >= _confidenceThreshold) {
        _currentResult = result;
        _state = ScanState.detected;

        // Stop scanning if auto continuous is off
        if (!_autoContinuousScan) {
          await _cameraService.stopImageStream();
        }

        // Play feedback
        await _audioService.playSuccessSound();
        await _hapticService.successFeedback();

        // Save to history
        await _saveToHistory(result);

        notifyListeners();
      }
    } catch (e) {
      // Continue scanning on error
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _saveToHistory(OcrResult result) async {
    final scanResult = ScanResult(
      id: const Uuid().v4(),
      plateNumber: result.plateNumber,
      confidence: result.confidence,
      vehicleType: result.vehicleType,
      scannedAt: result.timestamp,
      boundingBox: result.boundingBox,
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
