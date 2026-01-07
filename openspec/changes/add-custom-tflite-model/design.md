# Design: TFLite OCR (Image-based)

## Pipeline

```
Image File → Preprocess → Plate Detection → Crop → OCR → Result
                              ↓
                         (TFLite model)
```

## Models

| Model | Purpose | Input | Output |
|-------|---------|-------|--------|
| plate_detector.tflite | Detect plate region | 640x640 RGB | Bounding boxes |
| plate_ocr.tflite | Read characters | 100x32 grayscale | Character sequence |

## File Structure

```
lib/services/ocr/
├── ocr_service.dart           # Updated
└── tflite/
    ├── tflite_service.dart    # Model loading
    ├── plate_detector.dart    # Detection
    └── plate_ocr.dart         # Character recognition

assets/models/
├── plate_detector.tflite
├── plate_ocr.tflite
└── labels.txt
```

## Fallback

```
TFLite OCR (confidence > 0.7)
    ↓ fail
ML Kit OCR (existing)
    ↓ fail
Return null
```
