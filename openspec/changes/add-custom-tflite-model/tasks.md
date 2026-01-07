# Tasks: Custom TFLite OCR (Image-based)

## 1. Setup
- [ ] 1.1 Add `tflite_flutter` to pubspec.yaml
- [ ] 1.2 Configure Android/iOS for TFLite
- [ ] 1.3 Add model files to assets/models/

## 2. TFLite Service
- [ ] 2.1 Create `TfliteService` - load/run models
- [ ] 2.2 Implement plate detection from image
- [ ] 2.3 Implement character recognition from plate region

## 3. Integration
- [ ] 3.1 Add `processImageWithTflite()` to OcrService
- [ ] 3.2 Implement image preprocessing (resize, normalize)
- [ ] 3.3 Add fallback: TFLite -> ML Kit

## 4. Test
- [ ] 4.1 Test with sample plate images
- [ ] 4.2 Compare accuracy TFLite vs ML Kit
