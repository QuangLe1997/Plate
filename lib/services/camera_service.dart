import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  CameraDescription? _selectedCamera;
  bool _isInitialized = false;
  bool _isFlashOn = false;
  ResolutionPreset _resolution = ResolutionPreset.high;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isFlashOn => _isFlashOn;
  bool get isStreaming => _controller?.value.isStreamingImages ?? false;

  Future<void> initialize({
    ResolutionPreset resolution = ResolutionPreset.high,
  }) async {
    debugPrint('=== [CameraService] initialize()');
    _resolution = resolution;

    try {
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      // Find back camera
      _selectedCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      await _createController();
      debugPrint('=== [CameraService] Camera initialized successfully');
    } catch (e) {
      _isInitialized = false;
      debugPrint('=== [CameraService] Initialize ERROR: $e');
      rethrow;
    }
  }

  Future<void> _createController() async {
    debugPrint('=== [CameraService] _createController()');

    if (_selectedCamera == null) {
      debugPrint('=== [CameraService] ERROR: _selectedCamera is null');
      return;
    }

    try {
      // Use nv21 on Android for better compatibility, yuv420 on iOS
      final imageFormat = Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.yuv420;

      _controller = CameraController(
        _selectedCamera!,
        _resolution,
        enableAudio: false,
        imageFormatGroup: imageFormat,
      );

      await _controller!.initialize();
      _isInitialized = true;
      debugPrint('=== [CameraService] Controller created successfully');
    } catch (e) {
      debugPrint('=== [CameraService] _createController ERROR: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> startImageStream(
    void Function(CameraImage image) onImage,
  ) async {
    debugPrint('=== [CameraService] startImageStream()');

    // If camera not initialized yet, initialize first
    if (_selectedCamera == null) {
      debugPrint('=== [CameraService] Camera not initialized, initializing...');
      await initialize(resolution: _resolution);
    }

    // Re-create controller if disposed
    if (_controller == null || !_isInitialized) {
      debugPrint('=== [CameraService] Re-creating controller...');
      await _createController();
    }

    // Safety check
    if (_controller == null) {
      debugPrint('=== [CameraService] ERROR: Controller still null after init');
      return;
    }

    // Stop existing stream before starting new one
    if (_controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }

    await _controller!.startImageStream(onImage);
    debugPrint('=== [CameraService] Image stream STARTED');
  }

  Future<void> stopImageStream() async {
    debugPrint('=== [CameraService] stopImageStream()');
    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
      debugPrint('=== [CameraService] Image stream STOPPED');
    }
  }

  /// COMPLETELY turn off camera - dispose controller
  Future<void> pauseCamera() async {
    debugPrint('=== [CameraService] pauseCamera() - DISPOSING CONTROLLER');

    // Stop image stream first
    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }

    // Turn off flash
    if (_isFlashOn && _controller != null) {
      try {
        await _controller!.setFlashMode(FlashMode.off);
      } catch (e) {
        // Ignore
      }
      _isFlashOn = false;
    }

    // Dispose controller - this truly turns off the camera
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;

    debugPrint('=== [CameraService] Camera DISPOSED - Icon should disappear');
  }

  /// Resume camera after pause
  Future<void> resumeCamera() async {
    debugPrint('=== [CameraService] resumeCamera()');

    try {
      // If no camera selected, need full initialization
      if (_selectedCamera == null) {
        debugPrint('=== [CameraService] No camera selected, calling initialize');
        await initialize(resolution: _resolution);
        return;
      }

      // Re-create controller if disposed
      if (_controller == null || !_isInitialized) {
        await _createController();
        debugPrint('=== [CameraService] Camera RESUMED');
      }
    } catch (e) {
      debugPrint('=== [CameraService] resumeCamera ERROR: $e');
      // Try full re-initialization
      _selectedCamera = null;
      _controller = null;
      _isInitialized = false;
      await initialize(resolution: _resolution);
    }
  }

  Future<XFile?> takePicture() async {
    if (!_isInitialized || _controller == null) {
      return null;
    }

    try {
      // Stop streaming if active
      if (_controller!.value.isStreamingImages) {
        await stopImageStream();
      }

      return await _controller!.takePicture();
    } catch (e) {
      return null;
    }
  }

  Future<void> toggleFlash() async {
    if (!_isInitialized || _controller == null) {
      return;
    }

    try {
      _isFlashOn = !_isFlashOn;
      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      _isFlashOn = false;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (!_isInitialized || _controller == null) {
      return;
    }

    try {
      await _controller!.setFlashMode(mode);
      _isFlashOn = mode == FlashMode.torch || mode == FlashMode.always;
    } catch (e) {
      // Ignore flash errors on devices without flash
    }
  }

  Future<void> setZoomLevel(double zoom) async {
    if (!_isInitialized || _controller == null) {
      return;
    }

    try {
      final minZoom = await _controller!.getMinZoomLevel();
      final maxZoom = await _controller!.getMaxZoomLevel();
      final clampedZoom = zoom.clamp(minZoom, maxZoom);
      await _controller!.setZoomLevel(clampedZoom);
    } catch (e) {
      // Ignore zoom errors
    }
  }

  Future<double> getMinZoomLevel() async {
    if (!_isInitialized || _controller == null) {
      return 1.0;
    }
    return await _controller!.getMinZoomLevel();
  }

  Future<double> getMaxZoomLevel() async {
    if (!_isInitialized || _controller == null) {
      return 1.0;
    }
    return await _controller!.getMaxZoomLevel();
  }

  Future<void> setFocusPoint(Offset point) async {
    if (!_isInitialized || _controller == null) {
      return;
    }

    try {
      await _controller!.setFocusPoint(point);
    } catch (e) {
      // Ignore focus errors on devices without focus support
    }
  }

  Future<void> setExposurePoint(Offset point) async {
    if (!_isInitialized || _controller == null) {
      return;
    }

    try {
      await _controller!.setExposurePoint(point);
    } catch (e) {
      // Ignore exposure errors
    }
  }

  void dispose() {
    debugPrint('=== [CameraService] dispose()');
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _isFlashOn = false;
  }
}
