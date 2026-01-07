# Change: Add Custom TFLite Model for License Plate OCR (Image-based)

## Why

Current ML Kit generic text recognition has limited accuracy for Vietnamese license plates.
Need custom TFLite model for better on-device plate recognition from images.

## What Changes

- **ADDED**: TFLite model integration for plate detection + OCR
- **ADDED**: Image-based OCR processing pipeline
- **MODIFIED**: OcrService to support TFLite backend for image files

## Impact

- Affected specs: `ocr-model`
- Affected code:
  - `lib/services/ocr/ocr_service.dart`
  - `lib/services/ocr/tflite/`
  - `assets/models/`
