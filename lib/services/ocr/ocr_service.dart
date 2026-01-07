import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'models/ocr_result.dart';
import '../../core/utils/plate_formatter.dart';
import '../../core/utils/plate_validator.dart';

abstract class IOcrService {
  Future<void> initialize();
  Future<OcrResult?> processFrame(CameraImage image);
  Future<OcrResult?> processImageFile(String imagePath);
  void dispose();
}

class OcrService implements IOcrService {
  final TextRecognizer _textRecognizer;
  bool _isInitialized = false;
  bool _isProcessing = false;

  OcrService()
      : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  bool get isInitialized => _isInitialized;
  bool get isProcessing => _isProcessing;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<OcrResult?> processFrame(CameraImage image) async {
    if (!_isInitialized || _isProcessing) return null;

    _isProcessing = true;

    try {
      // Convert CameraImage to InputImage
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return null;
      }

      final result = await _processInputImage(inputImage);
      _isProcessing = false;
      return result;
    } catch (e) {
      _isProcessing = false;
      return null;
    }
  }

  @override
  Future<OcrResult?> processImageFile(String imagePath) async {
    if (!_isInitialized) return null;

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      return await _processInputImage(inputImage);
    } catch (e) {
      return null;
    }
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final format = _getInputImageFormat(image.format.group);
      if (format == null) return null;

      final plane = image.planes.first;

      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  InputImageFormat? _getInputImageFormat(ImageFormatGroup group) {
    switch (group) {
      case ImageFormatGroup.nv21:
        return InputImageFormat.nv21;
      case ImageFormatGroup.yuv420:
        return InputImageFormat.yuv420;
      case ImageFormatGroup.bgra8888:
        return InputImageFormat.bgra8888;
      default:
        return null;
    }
  }

  Future<OcrResult?> _processInputImage(InputImage inputImage) async {
    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        return null;
      }

      // Find license plate in recognized text
      final plateResult = _extractPlateNumber(recognizedText);

      if (plateResult == null) {
        return null;
      }

      return OcrResult(
        plateNumber: plateResult.plateNumber,
        confidence: plateResult.confidence,
        boundingBox: plateResult.boundingBox ?? Rect.zero,
        vehicleType: PlateValidator.getVehicleType(plateResult.plateNumber) ?? 'unknown',
      );
    } catch (e) {
      return null;
    }
  }

  _PlateResult? _extractPlateNumber(RecognizedText recognizedText) {
    final candidates = <_PlateResult>[];

    // Process each text block
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final text = line.text;
        final formatted = PlateFormatter.format(text);

        if (PlateValidator.isValid(formatted)) {
          final validationScore = PlateValidator.getValidationScore(formatted);
          candidates.add(_PlateResult(
            plateNumber: formatted,
            confidence: validationScore,
            boundingBox: line.boundingBox,
          ));
        }
      }
    }

    // Also try combining adjacent lines (for 2-line plates)
    final allLines = recognizedText.blocks.expand((b) => b.lines).toList();
    for (int i = 0; i < allLines.length - 1; i++) {
      final combined = PlateFormatter.formatTwoLines(
        allLines[i].text,
        allLines[i + 1].text,
      );

      if (PlateValidator.isValid(combined)) {
        final validationScore = PlateValidator.getValidationScore(combined);
        candidates.add(_PlateResult(
          plateNumber: combined,
          confidence: validationScore,
          boundingBox: allLines[i].boundingBox.expandToInclude(
            allLines[i + 1].boundingBox,
          ),
        ));
      }
    }

    if (candidates.isEmpty) {
      // Return raw text if looks like a plate pattern
      final rawText = PlateFormatter.format(recognizedText.text);
      if (rawText.length >= 7 && rawText.length <= 12) {
        return _PlateResult(
          plateNumber: rawText,
          confidence: 0.5,
          boundingBox: null,
        );
      }
      return null;
    }

    // Sort by confidence and return best match
    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));
    return candidates.first;
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _isInitialized = false;
    _isProcessing = false;
  }
}

class _PlateResult {
  final String plateNumber;
  final double confidence;
  final Rect? boundingBox;

  _PlateResult({
    required this.plateNumber,
    required this.confidence,
    this.boundingBox,
  });
}
