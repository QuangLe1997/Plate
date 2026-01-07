import 'dart:ui';

class ScanResult {
  final String id;
  final String plateNumber;
  final double confidence;
  final String vehicleType; // 'car' | 'motorbike' | 'unknown'
  final DateTime scannedAt;
  final Rect? boundingBox;
  final String? imagePath;

  ScanResult({
    required this.id,
    required this.plateNumber,
    required this.confidence,
    required this.vehicleType,
    required this.scannedAt,
    this.boundingBox,
    this.imagePath,
  });

  // Copy with
  ScanResult copyWith({
    String? id,
    String? plateNumber,
    double? confidence,
    String? vehicleType,
    DateTime? scannedAt,
    Rect? boundingBox,
    String? imagePath,
  }) {
    return ScanResult(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      confidence: confidence ?? this.confidence,
      vehicleType: vehicleType ?? this.vehicleType,
      scannedAt: scannedAt ?? this.scannedAt,
      boundingBox: boundingBox ?? this.boundingBox,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  // From JSON (for database)
  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      id: json['id'] as String,
      plateNumber: json['plate_number'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      vehicleType: json['vehicle_type'] as String,
      scannedAt: DateTime.parse(json['scanned_at'] as String),
      imagePath: json['image_path'] as String?,
    );
  }

  // To JSON (for database)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plate_number': plateNumber,
      'confidence': confidence,
      'vehicle_type': vehicleType,
      'scanned_at': scannedAt.toIso8601String(),
      'image_path': imagePath,
    };
  }

  // Get formatted confidence as percentage
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

  // Get vehicle type icon
  String get vehicleTypeIcon {
    switch (vehicleType) {
      case 'car':
        return 'car';
      case 'motorbike':
        return 'motorcycle';
      default:
        return 'help';
    }
  }

  @override
  String toString() {
    return 'ScanResult(id: $id, plateNumber: $plateNumber, confidence: $confidence, vehicleType: $vehicleType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScanResult && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
