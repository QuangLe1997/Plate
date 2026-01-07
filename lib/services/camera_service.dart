import 'dart:ui';

import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isFlashOn = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isFlashOn => _isFlashOn;

  Future<void> initialize({
    ResolutionPreset resolution = ResolutionPreset.high,
  }) async {
    try {
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      // Find back camera
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        backCamera,
        resolution,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> startImageStream(
    void Function(CameraImage image) onImage,
  ) async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    await _controller!.startImageStream(onImage);
  }

  Future<void> stopImageStream() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
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
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _isFlashOn = false;
  }
}
