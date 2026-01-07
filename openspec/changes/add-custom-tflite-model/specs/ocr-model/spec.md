# OCR Model Specification

## ADDED Requirements

### Requirement: TFLite Model Loading
The system SHALL load TFLite models for on-device plate recognition.

#### Scenario: Models loaded successfully
- **WHEN** TfliteService.initialize() is called
- **THEN** plate_detector.tflite is loaded
- **AND** plate_ocr.tflite is loaded

#### Scenario: Model loading fails
- **WHEN** model file is missing or corrupted
- **THEN** system falls back to ML Kit

### Requirement: Image-based Plate Detection
The system SHALL detect license plate regions from image files.

#### Scenario: Plate detected in image
- **WHEN** processImageWithTflite(imagePath) is called with valid plate image
- **THEN** bounding box of plate region is returned
- **AND** confidence score is provided

#### Scenario: No plate in image
- **WHEN** image contains no license plate
- **THEN** empty result is returned

### Requirement: Plate Character Recognition
The system SHALL recognize characters from detected plate region.

#### Scenario: Vietnamese plate recognized
- **WHEN** plate region is cropped and processed
- **THEN** plate number string is returned
- **AND** vehicle type (car/motorbike) is identified

### Requirement: Fallback to ML Kit
The system SHALL fallback to ML Kit when TFLite fails.

#### Scenario: TFLite low confidence
- **WHEN** TFLite returns confidence below 0.7
- **THEN** system tries ML Kit OCR
- **AND** returns better result
