# Vietnamese License Plate - Model Guide

## Recommended Pre-trained Models

### 1. Plate Detection: YOLOv8 (tungedng2710)

**Repository:** [tungedng2710/license-plate-recognition](https://github.com/tungedng2710/license-plate-recognition)

**Features:**
- YOLOv8 trained on Vietnamese plates
- Vehicle detection + Plate detection
- Updated July 2024 with PPOCRv4
- Pre-trained weights in `weights/` folder

**Download:**
```bash
git clone https://github.com/tungedng2710/license-plate-recognition.git
cd license-plate-recognition

# Weights are in weights/ folder
ls weights/
```

### 2. OCR: PaddleOCR v4

PaddleOCR is used for character recognition. For mobile, use **Paddle-Lite** format (not TFLite).

**Alternative for TFLite:** Train custom CRNN model or use EasyOCR converted to TFLite.

---

## Convert YOLOv8 to TFLite

### Step 1: Install Ultralytics

```bash
pip install ultralytics
```

### Step 2: Export to TFLite

```python
from ultralytics import YOLO

# Load Vietnamese plate detector weights
model = YOLO("weights/plate_detector.pt")  # your weights file

# Export to TFLite (INT8 quantized for mobile)
model.export(
    format="tflite",
    imgsz=320,      # smaller = faster on mobile
    int8=True,      # quantize for smaller size
)
# Output: plate_detector_int8.tflite (~5MB)
```

**CLI alternative:**
```bash
yolo export model=weights/plate_detector.pt format=tflite imgsz=320 int8=True
```

### Step 3: Export to CoreML (iOS)

```python
model.export(
    format="coreml",
    imgsz=320,
    half=True,      # FP16 for iOS
    nms=True,       # Required for detection on iOS
)
# Output: plate_detector.mlpackage
```

---

## Flutter Integration

### Option A: ultralytics_yolo (Recommended)

**Supports:** Android + iOS

```yaml
# pubspec.yaml
dependencies:
  ultralytics_yolo: ^0.0.4
```

**Setup:**
```
# Android
android/app/src/main/assets/
├── plate_detector.tflite
└── labels.txt

# iOS
ios/Runner/
├── plate_detector.mlpackage
└── labels.txt
```

**Usage:**
```dart
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

// Detection
YOLOView(
  modelPath: 'plate_detector',
  task: YOLOTask.detect,
  onResult: (results) {
    for (final result in results) {
      print('Plate found: ${result.boundingBox}');
    }
  },
)
```

### Option B: flutter_vision (Android only)

```yaml
dependencies:
  flutter_vision: ^1.1.4
```

```dart
final vision = FlutterVision();

await vision.loadYoloModel(
  modelPath: 'assets/plate_detector.tflite',
  labels: 'assets/labels.txt',
  modelVersion: 'yolov8',
  numThreads: 4,
  useGpu: true,
);

// Detect from image
final results = await vision.yoloOnImage(
  bytesList: imageBytes,
  imageHeight: height,
  imageWidth: width,
);
```

---

## Model Files Needed

| File | Purpose | Size | Format |
|------|---------|------|--------|
| `plate_detector.tflite` | Detect plate region | ~5MB | Android |
| `plate_detector.mlpackage` | Detect plate region | ~5MB | iOS |
| `plate_ocr.tflite` | Read characters | ~3MB | Both |
| `labels.txt` | Class labels | <1KB | Both |

---

## Quick Start Script

```bash
# 1. Clone Vietnamese plate repo
git clone https://github.com/tungedng2710/license-plate-recognition.git
cd license-plate-recognition

# 2. Install dependencies
pip install ultralytics paddleocr

# 3. Convert plate detector to TFLite
python -c "
from ultralytics import YOLO
model = YOLO('weights/plate_yolov8.pt')  # adjust path
model.export(format='tflite', imgsz=320, int8=True)
print('Done! Check plate_yolov8_int8.tflite')
"

# 4. Convert to CoreML for iOS
python -c "
from ultralytics import YOLO
model = YOLO('weights/plate_yolov8.pt')
model.export(format='coreml', imgsz=320, half=True, nms=True)
print('Done! Check plate_yolov8.mlpackage')
"
```

---

## Alternative Models

| Repository | Detection | OCR | Notes |
|------------|-----------|-----|-------|
| [tungedng2710](https://github.com/tungedng2710/license-plate-recognition) | YOLOv8 | PaddleOCR | Best, updated 2024 |
| [trungdinh22](https://github.com/trungdinh22/License-Plate-Recognition) | YOLOv5 | CNN | 1-line & 2-line plates |
| [mrzaizai2k](https://github.com/mrzaizai2k/License-Plate-Recognition-YOLOv7-and-CNN) | YOLOv7 | CNN | Weights in releases |
| [Roboflow](https://universe.roboflow.com/tran-ngoc-xuan-tin-k15-hcm-dpuid/vietnam-license-plate-h8t3n) | Various | - | 1005 images dataset |

---

## OCR Options for Mobile

### Option 1: PaddleOCR with Paddle-Lite (Native)

```bash
# Convert PaddleOCR to Paddle-Lite format
paddle_lite_opt --model_dir=./inference/ch_ppocr_mobile_v2.0_rec_infer \
                --optimize_out=./ch_rec_opt \
                --valid_targets=arm
# Output: ch_rec_opt.nb
```

### Option 2: Google ML Kit (Current - Fallback)

Already implemented in `ocr_service.dart`. Use as fallback when TFLite fails.

### Option 3: Custom CRNN TFLite

Train CRNN on Vietnamese plate characters (0-9, A-Z) and export to TFLite.

**Recommendation:** Start with YOLOv8 detection + ML Kit OCR, then add custom OCR later.

---

## Performance Expectations

| Model | Size | Inference (Android) | Inference (iOS) |
|-------|------|---------------------|-----------------|
| YOLOv8n INT8 | ~5MB | ~30ms | ~25ms |
| YOLOv8s INT8 | ~15MB | ~50ms | ~40ms |
| OCR CRNN | ~3MB | ~20ms | ~15ms |

**Target:** <100ms total pipeline (detection + OCR)
