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

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview - use SizedBox.expand to fill screen
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller!.value.previewSize?.height ?? 1920,
              height: controller!.value.previewSize?.width ?? 1080,
              child: CameraPreview(controller!),
            ),
          ),
        ),
        // Overlay
        if (overlay != null) overlay!,
      ],
    );
  }
}
