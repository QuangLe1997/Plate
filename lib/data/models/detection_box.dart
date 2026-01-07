import 'dart:ui';

class DetectionBox {
  final Rect rect;
  final double confidence;
  final String? label;

  DetectionBox({
    required this.rect,
    required this.confidence,
    this.label,
  });

  // Factory constructor from model output
  factory DetectionBox.fromModelOutput({
    required double x,
    required double y,
    required double width,
    required double height,
    required double confidence,
    required int imageWidth,
    required int imageHeight,
    String? label,
  }) {
    // Convert normalized coordinates to pixel coordinates
    final left = x * imageWidth;
    final top = y * imageHeight;
    final boxWidth = width * imageWidth;
    final boxHeight = height * imageHeight;

    return DetectionBox(
      rect: Rect.fromLTWH(left, top, boxWidth, boxHeight),
      confidence: confidence,
      label: label,
    );
  }

  // Scale box to different image dimensions
  DetectionBox scaleTo(int targetWidth, int targetHeight, int originalWidth, int originalHeight) {
    final scaleX = targetWidth / originalWidth;
    final scaleY = targetHeight / originalHeight;

    return DetectionBox(
      rect: Rect.fromLTWH(
        rect.left * scaleX,
        rect.top * scaleY,
        rect.width * scaleX,
        rect.height * scaleY,
      ),
      confidence: confidence,
      label: label,
    );
  }

  // Get center point
  Offset get center => rect.center;

  // Get area
  double get area => rect.width * rect.height;

  // Check if box is valid (has positive dimensions)
  bool get isValid => rect.width > 0 && rect.height > 0 && confidence > 0;

  // Get confidence as percentage string
  String get confidencePercent => '${(confidence * 100).toInt()}%';

  // Expand box by padding
  DetectionBox expand(double padding) {
    return DetectionBox(
      rect: Rect.fromLTWH(
        rect.left - padding,
        rect.top - padding,
        rect.width + padding * 2,
        rect.height + padding * 2,
      ),
      confidence: confidence,
      label: label,
    );
  }

  // Clamp box to image bounds
  DetectionBox clampTo(int imageWidth, int imageHeight) {
    return DetectionBox(
      rect: Rect.fromLTRB(
        rect.left.clamp(0, imageWidth.toDouble()),
        rect.top.clamp(0, imageHeight.toDouble()),
        rect.right.clamp(0, imageWidth.toDouble()),
        rect.bottom.clamp(0, imageHeight.toDouble()),
      ),
      confidence: confidence,
      label: label,
    );
  }

  @override
  String toString() {
    return 'DetectionBox(rect: $rect, confidence: $confidence, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DetectionBox &&
        other.rect == rect &&
        other.confidence == confidence &&
        other.label == label;
  }

  @override
  int get hashCode => Object.hash(rect, confidence, label);
}
