import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController? controller;
  final Widget? overlay;

  const CameraPreviewWidget({
    super.key,
    this.controller,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cameraAspectRatio = controller!.value.aspectRatio;
        final screenAspectRatio = constraints.maxWidth / constraints.maxHeight;

        double scale;
        if (screenAspectRatio > cameraAspectRatio) {
          scale = constraints.maxWidth / (constraints.maxHeight * cameraAspectRatio);
        } else {
          scale = (constraints.maxWidth / cameraAspectRatio) / constraints.maxHeight;
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview
            ClipRect(
              child: Transform.scale(
                scale: scale,
                child: Center(
                  child: CameraPreview(controller!),
                ),
              ),
            ),
            // Overlay
            if (overlay != null) overlay!,
          ],
        );
      },
    );
  }
}
