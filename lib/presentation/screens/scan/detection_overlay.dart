import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/detection_box.dart';

class DetectionOverlay extends StatelessWidget {
  final DetectionBox? detectionBox;
  final Size previewSize;
  final Size screenSize;

  const DetectionOverlay({
    super.key,
    this.detectionBox,
    required this.previewSize,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    if (detectionBox == null) {
      return const SizedBox.shrink();
    }

    // Scale the detection box to screen coordinates
    final scaleX = screenSize.width / previewSize.width;
    final scaleY = screenSize.height / previewSize.height;

    final scaledRect = Rect.fromLTWH(
      detectionBox!.rect.left * scaleX,
      detectionBox!.rect.top * scaleY,
      detectionBox!.rect.width * scaleX,
      detectionBox!.rect.height * scaleY,
    );

    return CustomPaint(
      size: screenSize,
      painter: _DetectionBoxPainter(
        rect: scaledRect,
        confidence: detectionBox!.confidence,
      ),
    );
  }
}

class _DetectionBoxPainter extends CustomPainter {
  final Rect rect;
  final double confidence;

  _DetectionBoxPainter({
    required this.rect,
    required this.confidence,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.boundingBox
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw bounding box
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rrect, paint);

    // Draw corner accents
    final accentPaint = Paint()
      ..color = AppColors.boundingBox
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    const cornerLength = 20.0;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      accentPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      accentPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      accentPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      accentPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      accentPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      accentPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      accentPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      accentPaint,
    );

    // Draw confidence label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(confidence * 100).toInt()}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final labelRect = Rect.fromLTWH(
      rect.left,
      rect.top - 24,
      textPainter.width + 16,
      22,
    );

    // Draw label background
    final labelPaint = Paint()..color = AppColors.boundingBox;
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
      labelPaint,
    );

    // Draw label text
    textPainter.paint(
      canvas,
      Offset(labelRect.left + 8, labelRect.top + 3),
    );
  }

  @override
  bool shouldRepaint(covariant _DetectionBoxPainter oldDelegate) {
    return oldDelegate.rect != rect || oldDelegate.confidence != confidence;
  }
}
