import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class GuideFrame extends StatelessWidget {
  final double width;
  final double height;
  final double cornerRadius;
  final double strokeWidth;
  final double cornerLength;
  final Color color;

  const GuideFrame({
    super.key,
    this.width = 300,
    this.height = 100,
    this.cornerRadius = 12,
    this.strokeWidth = 3,
    this.cornerLength = 30,
    this.color = AppColors.guideFrame,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _GuideFramePainter(
        cornerRadius: cornerRadius,
        strokeWidth: strokeWidth,
        cornerLength: cornerLength,
        color: color,
      ),
    );
  }
}

class _GuideFramePainter extends CustomPainter {
  final double cornerRadius;
  final double strokeWidth;
  final double cornerLength;
  final Color color;

  _GuideFramePainter({
    required this.cornerRadius,
    required this.strokeWidth,
    required this.cornerLength,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw corners only
    final path = Path();

    // Top-left corner
    path.moveTo(0, cornerLength);
    path.lineTo(0, cornerRadius);
    path.arcToPoint(
      Offset(cornerRadius, 0),
      radius: Radius.circular(cornerRadius),
    );
    path.lineTo(cornerLength, 0);

    // Top-right corner
    path.moveTo(size.width - cornerLength, 0);
    path.lineTo(size.width - cornerRadius, 0);
    path.arcToPoint(
      Offset(size.width, cornerRadius),
      radius: Radius.circular(cornerRadius),
    );
    path.lineTo(size.width, cornerLength);

    // Bottom-right corner
    path.moveTo(size.width, size.height - cornerLength);
    path.lineTo(size.width, size.height - cornerRadius);
    path.arcToPoint(
      Offset(size.width - cornerRadius, size.height),
      radius: Radius.circular(cornerRadius),
    );
    path.lineTo(size.width - cornerLength, size.height);

    // Bottom-left corner
    path.moveTo(cornerLength, size.height);
    path.lineTo(cornerRadius, size.height);
    path.arcToPoint(
      Offset(0, size.height - cornerRadius),
      radius: Radius.circular(cornerRadius),
    );
    path.lineTo(0, size.height - cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GuideFramePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.cornerLength != cornerLength;
  }
}

class GuideFrameOverlay extends StatelessWidget {
  final double aspectRatio;
  final double widthFactor;

  const GuideFrameOverlay({
    super.key,
    this.aspectRatio = 3.0, // Width:Height ratio for license plate
    this.widthFactor = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameWidth = constraints.maxWidth * widthFactor;
        final frameHeight = frameWidth / aspectRatio;

        return Stack(
          children: [
            // Semi-transparent overlay
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Center(
                    child: Container(
                      width: frameWidth,
                      height: frameHeight,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Guide frame corners
            Center(
              child: GuideFrame(
                width: frameWidth,
                height: frameHeight,
              ),
            ),
          ],
        );
      },
    );
  }
}
