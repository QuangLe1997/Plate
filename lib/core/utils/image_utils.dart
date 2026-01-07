import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';

class ImageUtils {
  ImageUtils._();

  /// Convert CameraImage to Uint8List (raw bytes)
  static Uint8List? cameraImageToBytes(CameraImage image) {
    try {
      // Return the Y plane bytes for processing
      return image.planes[0].bytes;
    } catch (e) {
      return null;
    }
  }

  /// Get image dimensions from CameraImage
  static ui.Size getCameraImageSize(CameraImage image) {
    return ui.Size(image.width.toDouble(), image.height.toDouble());
  }
}
