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
    this.cornerRadius = 16,
    this.strokeWidth = 4,
    this.cornerLength = 40,
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

class GuideFrameOverlay extends StatefulWidget {
  final double aspectRatio;
  final double widthFactor;
  final bool isScanning;

  const GuideFrameOverlay({
    super.key,
    this.aspectRatio = 2.5, // Width:Height ratio for license plate (wider frame)
    this.widthFactor = 0.92, // Maximum scan area
    this.isScanning = false,
  });

  @override
  State<GuideFrameOverlay> createState() => _GuideFrameOverlayState();
}

class _GuideFrameOverlayState extends State<GuideFrameOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameWidth = constraints.maxWidth * widget.widthFactor;
        final frameHeight = frameWidth / widget.aspectRatio;

        // Position frame at center for maximum camera view
        final topOffset = (constraints.maxHeight - frameHeight) / 2 - 20;

        return Stack(
          children: [
            // Semi-transparent overlay with cutout - minimal opacity for maximum camera view
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withAlpha(80), // Very low opacity for maximum camera visibility
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
                  Positioned(
                    left: (constraints.maxWidth - frameWidth) / 2,
                    top: topOffset,
                    child: Container(
                      width: frameWidth,
                      height: frameHeight,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Animated scan line
            Positioned(
              left: (constraints.maxWidth - frameWidth) / 2,
              top: topOffset,
              child: SizedBox(
                width: frameWidth,
                height: frameHeight,
                child: AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ScanLinePainter(
                        progress: _scanAnimation.value,
                        color: AppColors.primary.withOpacity(0.8),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Guide frame corners
            Positioned(
              left: (constraints.maxWidth - frameWidth) / 2,
              top: topOffset,
              child: GuideFrame(
                width: frameWidth,
                height: frameHeight,
                strokeWidth: 4,
                cornerLength: 45,
                cornerRadius: 16,
              ),
            ),

            // Instruction text below frame
            Positioned(
              left: 0,
              right: 0,
              top: topOffset + frameHeight + 24,
              child: const Column(
                children: [
                  Text(
                    'Di chuyen camera de bien so nam trong khung',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Dam bao anh sang du & bien so ro net',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScanLinePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0),
          color,
          color.withOpacity(0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 3));

    final y = progress * size.height;
    canvas.drawRect(
      Rect.fromLTWH(8, y, size.width - 16, 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
