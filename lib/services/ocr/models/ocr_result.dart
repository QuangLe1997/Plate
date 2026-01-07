import 'dart:ui';

class OcrResult {
  final String plateNumber;
  final double confidence;
  final Rect boundingBox;
  final String vehicleType;
  final DateTime timestamp;
  final List<String>? alternatives;

  OcrResult({
    required this.plateNumber,
    required this.confidence,
    required this.boundingBox,
    required this.vehicleType,
    DateTime? timestamp,
    this.alternatives,
  }) : timestamp = timestamp ?? DateTime.now();

  // Check if result is valid based on confidence threshold
  bool isValidWithThreshold(double threshold) {
    return confidence >= threshold;
  }

  // Get confidence as percentage string
  String get confidencePercent => '${(confidence * 100).toInt()}%';

  // Get vehicle type display name
  String get vehicleTypeDisplay {
    switch (vehicleType) {
      case 'car':
        return 'O to';
      case 'motorbike':
        return 'Xe may';
      default:
        return 'Khong xac dinh';
    }
  }

  // Create a copy with updated fields
  OcrResult copyWith({
    String? plateNumber,
    double? confidence,
    Rect? boundingBox,
    String? vehicleType,
    DateTime? timestamp,
    List<String>? alternatives,
  }) {
    return OcrResult(
      plateNumber: plateNumber ?? this.plateNumber,
      confidence: confidence ?? this.confidence,
      boundingBox: boundingBox ?? this.boundingBox,
      vehicleType: vehicleType ?? this.vehicleType,
      timestamp: timestamp ?? this.timestamp,
      alternatives: alternatives ?? this.alternatives,
    );
  }

  @override
  String toString() {
    return 'OcrResult(plateNumber: $plateNumber, confidence: ${confidencePercent}, vehicleType: $vehicleType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OcrResult &&
        other.plateNumber == plateNumber &&
        other.confidence == confidence &&
        other.boundingBox == boundingBox;
  }

  @override
  int get hashCode => Object.hash(plateNumber, confidence, boundingBox);
}
