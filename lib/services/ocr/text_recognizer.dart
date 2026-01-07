import 'dart:typed_data';
import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../core/utils/plate_formatter.dart';
import '../../core/utils/plate_validator.dart';

class PlateTextRecognizer {
  final TextRecognizer _textRecognizer;
  bool _isInitialized = false;

  PlateTextRecognizer()
      : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    _isInitialized = true;
  }

  Future<PlateRecognitionResult?> recognize(
    Uint8List croppedPlateBytes,
    int width,
    int height,
  ) async {
    try {
      final inputImage = InputImage.fromBytes(
        bytes: croppedPlateBytes,
        metadata: InputImageMetadata(
          size: Size(width.toDouble(), height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: width,
        ),
      );

      final result = await _textRecognizer.processImage(inputImage);

      if (result.text.isEmpty) {
        return null;
      }

      // Extract and format plate number
      return _extractPlateNumber(result);
    } catch (e) {
      return null;
    }
  }

  Future<PlateRecognitionResult?> recognizeFromFile(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final result = await _textRecognizer.processImage(inputImage);

      if (result.text.isEmpty) {
        return null;
      }

      return _extractPlateNumber(result);
    } catch (e) {
      return null;
    }
  }

  PlateRecognitionResult? _extractPlateNumber(RecognizedText result) {
    final candidates = <PlateCandidate>[];

    // Process each text block
    for (final block in result.blocks) {
      for (final line in block.lines) {
        final text = line.text;
        final formatted = PlateFormatter.format(text);

        if (PlateValidator.isValid(formatted)) {
          final validationScore = PlateValidator.getValidationScore(formatted);
          candidates.add(PlateCandidate(
            text: formatted,
            confidence: validationScore,
            boundingBox: line.boundingBox,
          ));
        }
      }
    }

    // Also try combining lines (for 2-line plates)
    if (result.blocks.isNotEmpty) {
      final allLines = result.blocks.expand((b) => b.lines).toList();
      for (int i = 0; i < allLines.length - 1; i++) {
        final combined = PlateFormatter.formatTwoLines(
          allLines[i].text,
          allLines[i + 1].text,
        );

        if (PlateValidator.isValid(combined)) {
          final validationScore = PlateValidator.getValidationScore(combined);
          candidates.add(PlateCandidate(
            text: combined,
            confidence: validationScore,
            boundingBox: allLines[i].boundingBox.expandToInclude(
              allLines[i + 1].boundingBox,
            ),
          ));
        }
      }
    }

    if (candidates.isEmpty) {
      // If no valid plate found, return the raw text as fallback
      final rawText = PlateFormatter.format(result.text);
      if (rawText.isNotEmpty) {
        return PlateRecognitionResult(
          plateNumber: rawText,
          confidence: 0.5,
          vehicleType: PlateValidator.getVehicleType(rawText),
          alternatives: [],
        );
      }
      return null;
    }

    // Sort by confidence and return best match
    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));

    final best = candidates.first;
    final alternatives = candidates
        .skip(1)
        .take(3)
        .map((c) => c.text)
        .toList();

    return PlateRecognitionResult(
      plateNumber: best.text,
      confidence: best.confidence,
      vehicleType: PlateValidator.getVehicleType(best.text),
      boundingBox: best.boundingBox,
      alternatives: alternatives,
    );
  }

  void dispose() {
    _textRecognizer.close();
    _isInitialized = false;
  }
}

class PlateCandidate {
  final String text;
  final double confidence;
  final Rect boundingBox;

  PlateCandidate({
    required this.text,
    required this.confidence,
    required this.boundingBox,
  });
}

class PlateRecognitionResult {
  final String plateNumber;
  final double confidence;
  final String? vehicleType;
  final Rect? boundingBox;
  final List<String> alternatives;

  PlateRecognitionResult({
    required this.plateNumber,
    required this.confidence,
    this.vehicleType,
    this.boundingBox,
    this.alternatives = const [],
  });

  String get confidencePercent => '${(confidence * 100).toInt()}%';

  @override
  String toString() {
    return 'PlateRecognitionResult(plateNumber: $plateNumber, confidence: $confidencePercent)';
  }
}
