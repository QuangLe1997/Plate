import 'dart:ui';

import '../../data/models/detection_box.dart';

/// Placeholder PlateDetector class
/// This is a stub - actual plate detection is handled by ML Kit text recognition
/// For production, you would integrate a proper YOLOv8 TFLite model here
class PlateDetector {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> loadModel() async {
    // ML Kit handles text detection, no custom model needed for MVP
    _isInitialized = true;
  }

  List<DetectionBox> detect(dynamic imageBytes, int imageWidth, int imageHeight) {
    // Placeholder - returns empty list
    // ML Kit text recognition handles the detection in OcrService
    return [];
  }

  void dispose() {
    _isInitialized = false;
  }
}
