class AppConstants {
  AppConstants._();

  // OCR Settings
  static const double defaultConfidenceThreshold = 0.8;
  static const double minConfidenceThreshold = 0.5;
  static const double maxConfidenceThreshold = 0.95;

  // Camera Settings
  static const double minZoom = 1.0;
  static const double maxZoom = 5.0;
  static const int targetFps = 30;

  // Detection Settings
  static const int inputSize = 640;
  static const double detectionConfidenceThreshold = 0.5;
  static const int maxPlatesPerFrame = 5;

  // History Settings
  static const int maxHistoryRecords = 100;

  // UI Constants
  static const double baseSpacing = 8.0;
  static const double screenPadding = 16.0;
  static const double cardPadding = 16.0;
  static const double cardRadius = 12.0;
  static const double buttonHeight = 48.0;
  static const double buttonRadius = 8.0;
  static const double iconSize = 24.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Splash Duration
  static const Duration splashDuration = Duration(seconds: 2);

  // Model Files
  static const String plateDetectorModel = 'assets/models/yolov8n_plate.tflite';
  static const String ocrRecognizerModel = 'assets/models/ppocr_rec.nb';

  // Sound Files
  static const String successSound = 'assets/sounds/beep.mp3';
}
