# 📋 Product Requirements Document (PRD)

# **PlateSnap** - Ứng dụng Quét & Nhận Diện Biển Số Xe

![PlateSnap Logo Concept](https://via.placeholder.com/200x60/2196F3/FFFFFF?text=PlateSnap)

---

## 📌 Document Info

| Thông tin | Chi tiết |
|-----------|----------|
| **Tên sản phẩm** | **PlateSnap** |
| **Tagline** | *"Quét biển số - Nhanh như chớp"* |
| **Version** | 1.0.0 - Phase 1 (MVP) |
| **Ngày tạo** | 07/01/2026 |
| **Loại dự án** | POC (Proof of Concept) |
| **Platform** | Mobile (Android & iOS) |
| **Focus Phase 1** | 🎯 **On-Device OCR - Nhận diện biển số xe ra text** |

---

## 1. 🎯 Executive Summary

### 1.1 Mục tiêu Phase 1

> **Xây dựng ứng dụng mobile (Android + iOS) có khả năng quét và nhận diện biển số xe Việt Nam, trả về text biển số. Toàn bộ xử lý OCR chạy trực tiếp trên thiết bị (on-device), không cần kết nối internet.**

### 1.2 Scope Phase 1 (MVP)

| Trong scope ✅ | Ngoài scope ❌ (Phase sau) |
|---------------|---------------------------|
| Camera preview với guide frame | Backend API |
| On-device license plate detection | Database lưu trữ thông tin xe |
| On-device OCR đọc biển số | Tra cứu thông tin chủ xe |
| Hiển thị text biển số đã nhận diện | Gọi điện/SMS |
| Copy text biển số | Admin management |
| Lịch sử quét (local storage) | Cloud sync |
| Hỗ trợ biển số xe máy VN (1 dòng, 2 dòng) | Biển số nước ngoài |
| Hỗ trợ biển số ô tô VN | Analytics/Reporting |

### 1.3 Success Metrics (Phase 1)

| Metric | Target | Measurement |
|--------|--------|-------------|
| **OCR Accuracy** | ≥ 90% | Test với 200 ảnh biển số VN |
| **Detection Speed** | < 500ms | Từ frame đến kết quả |
| **App Size** | < 50MB | APK/IPA size |
| **Crash Rate** | < 1% | Firebase Crashlytics |
| **Works Offline** | 100% | OCR không cần internet |

---

## 2. 🏗️ Product Vision

### 2.1 Tầm nhìn sản phẩm

**PlateSnap** là nền tảng nhận diện biển số xe thông minh, phục vụ:

```
Phase 1 (Current): App OCR độc lập
    ↓
Phase 2: Tích hợp Backend + Quản lý xe chung cư
    ↓
Phase 3: Mở rộng - Parking, Toll, Security
    ↓
Phase 4: Platform/SDK cho third-party
```

### 2.2 Target Users (Phase 1)

| User Type | Use Case |
|-----------|----------|
| Bảo vệ chung cư | Ghi nhận nhanh biển số xe ra/vào |
| Nhân viên bãi xe | Check biển số không cần gõ tay |
| Cá nhân | Ghi nhớ biển số khi cần (va chạm, đỗ xe...) |
| Developer | Test khả năng OCR trước khi tích hợp |

---

## 3. 📱 Functional Requirements (Phase 1)

### 3.1 Core Features

#### FR-01: Camera Module

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-01.1 | Mở camera rear-facing | **P0** | Camera khởi động < 1s |
| FR-01.2 | Hiển thị camera preview full screen | **P0** | Smooth 30fps |
| FR-01.3 | Hiển thị guide frame (khung hướng dẫn) | **P0** | Rect ở giữa màn hình |
| FR-01.4 | Toggle flash/torch | **P1** | Nút bật/tắt đèn flash |
| FR-01.5 | Auto-focus khi tap | **P1** | Focus vào vùng tap |
| FR-01.6 | Zoom in/out (pinch gesture) | **P2** | 1x - 5x zoom |

#### FR-02: License Plate Detection (YOLOv8)

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-02.1 | Detect vùng biển số trong frame | **P0** | Bounding box chính xác |
| FR-02.2 | Real-time detection (mỗi frame) | **P0** | ≥ 15 FPS detection |
| FR-02.3 | Hiển thị bounding box trên preview | **P0** | Overlay màu xanh |
| FR-02.4 | Confidence score | **P0** | Hiển thị % confidence |
| FR-02.5 | Hỗ trợ nhiều biển số trong 1 frame | **P2** | Detect tối đa 5 plates |

#### FR-03: OCR Text Recognition (PaddleOCR/ML Kit)

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-03.1 | Đọc text từ vùng biển số đã detect | **P0** | Output string |
| FR-03.2 | Hỗ trợ biển số xe máy 1 dòng | **P0** | VD: "59X1-12345" |
| FR-03.3 | Hỗ trợ biển số xe máy 2 dòng | **P0** | VD: "59X1" + "12345" |
| FR-03.4 | Hỗ trợ biển số ô tô | **P0** | VD: "51G-123.45" |
| FR-03.5 | Format chuẩn hóa output | **P0** | "59A-12345" format |
| FR-03.6 | Xử lý on-device (offline) | **P0** | Không gọi API |
| FR-03.7 | Confidence threshold configurable | **P1** | Default 80% |

#### FR-04: Result Display & Actions

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-04.1 | Hiển thị text biển số lớn, rõ ràng | **P0** | Font 28sp+, bold |
| FR-04.2 | Copy text vào clipboard | **P0** | Tap to copy |
| FR-04.3 | Hiển thị confidence score | **P1** | Percentage |
| FR-04.4 | Nút "Quét lại" | **P0** | Reset và quét mới |
| FR-04.5 | Âm thanh/haptic khi detect thành công | **P2** | Beep hoặc vibrate |

#### FR-05: Scan History (Local)

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-05.1 | Lưu lịch sử quét vào local storage | **P1** | SharedPreferences/SQLite |
| FR-05.2 | Hiển thị danh sách đã quét | **P1** | List view với timestamp |
| FR-05.3 | Xem chi tiết 1 record | **P1** | Plate + time + image (optional) |
| FR-05.4 | Xóa 1 record | **P2** | Swipe to delete |
| FR-05.5 | Xóa toàn bộ lịch sử | **P2** | Clear all button |
| FR-05.6 | Giới hạn lưu 100 records gần nhất | **P2** | Auto cleanup |

#### FR-06: Settings

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-06.1 | Bật/tắt âm thanh | **P2** | Toggle switch |
| FR-06.2 | Bật/tắt haptic feedback | **P2** | Toggle switch |
| FR-06.3 | Chọn confidence threshold | **P2** | Slider 50-95% |
| FR-06.4 | Xem thông tin app (version, about) | **P2** | Info screen |

---

## 4. 🎨 User Interface Design

### 4.1 Screen Flow (Phase 1)

```
┌─────────────────────────────────────────────────────────────┐
│                     PlateSnap App Flow                       │
└─────────────────────────────────────────────────────────────┘

[Splash Screen] ──▶ [Main Scan Screen] ◀──▶ [History Screen]
     (2s)                  │                       │
                           │                       │
                           ▼                       │
                    [Result Overlay]               │
                           │                       │
                           ├── Copy ───────────────┤
                           ├── Scan Again ─────────┤
                           └── View History ───────┘
                                                   
                                        [Settings Screen]
```

### 4.2 Screen Designs

#### 4.2.1 Splash Screen

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│                                 │
│         ┌───────────┐          │
│         │    🚗     │          │
│         │ PlateSnap │          │
│         └───────────┘          │
│                                 │
│      Quét biển số - Nhanh như chớp │
│                                 │
│         ◌ ◌ ◌ Loading          │
│                                 │
│                                 │
│                                 │
│            v1.0.0              │
└─────────────────────────────────┘
```

#### 4.2.2 Main Scan Screen (Core Screen)

```
┌─────────────────────────────────┐
│ PlateSnap              ⚙️  📋  │  ◄── Header: Settings + History
├─────────────────────────────────┤
│                                 │
│  ┌─────────────────────────┐   │
│  │                         │   │
│  │                         │   │
│  │    ╔═══════════════╗    │   │
│  │    ║               ║    │   │  ◄── Camera Preview
│  │    ║  [Guide Frame]║    │   │      với Guide Frame
│  │    ║               ║    │   │
│  │    ╚═══════════════╝    │   │
│  │                         │   │
│  │                         │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 🎯 Detecting...         │   │  ◄── Status indicator
│  └─────────────────────────┘   │
│                                 │
│  Hướng camera vào biển số xe   │  ◄── Instruction text
│                                 │
│         [🔦]                   │  ◄── Flash toggle button
│                                 │
└─────────────────────────────────┘
```

#### 4.2.3 Detection Active State

```
┌─────────────────────────────────┐
│ PlateSnap              ⚙️  📋  │
├─────────────────────────────────┤
│                                 │
│  ┌─────────────────────────┐   │
│  │                         │   │
│  │    ┌───────────────┐    │   │
│  │    │ ┌───────────┐ │    │   │
│  │    │ │  59A-123  │ │    │   │  ◄── Bounding box
│  │    │ │   45      │ │    │   │      màu xanh lá
│  │    │ └───────────┘ │    │   │
│  │    └───────────────┘    │   │
│  │                         │   │
│  │                         │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ ✅ Detected: 59A-12345  │   │  ◄── Real-time result
│  │    Confidence: 94%      │   │
│  └─────────────────────────┘   │
│                                 │
│  ════════════════════════════  │  ◄── Progress bar
│                                 │
│         [🔦]      [📸]         │  ◄── Flash + Capture
│                                 │
└─────────────────────────────────┘
```

#### 4.2.4 Result Screen (Bottom Sheet / Overlay)

```
┌─────────────────────────────────┐
│                                 │
│  (Camera preview dimmed)        │
│                                 │
├─────────────────────────────────┤  ◄── Bottom Sheet
│  ═══════════════════════════   │      slides up
│                                 │
│         ✅ Thành công!          │
│                                 │
│  ┌─────────────────────────┐   │
│  │                         │   │
│  │      59A - 12345        │   │  ◄── Plate number
│  │                         │   │      Large, bold
│  └─────────────────────────┘   │
│                                 │
│  Confidence: 94%    🚗 Ô tô    │  ◄── Details
│                                 │
│  ┌───────────┐ ┌───────────┐   │
│  │  📋 COPY  │ │ 🔄 QUÉT   │   │  ◄── Action buttons
│  │           │ │    LẠI    │   │
│  └───────────┘ └───────────┘   │
│                                 │
│  ─────────────────────────────  │
│  Quét lúc: 07/01/2026 14:35    │
│                                 │
└─────────────────────────────────┘
```

#### 4.2.5 History Screen

```
┌─────────────────────────────────┐
│ ←  Lịch sử quét         🗑️     │  ◄── Back + Clear all
├─────────────────────────────────┤
│                                 │
│  🔍 Tìm kiếm biển số...        │  ◄── Search bar
│                                 │
│  ─────────────────────────────  │
│  Hôm nay                        │
│  ─────────────────────────────  │
│  ┌─────────────────────────┐   │
│  │ 🚗 59A-12345            │   │
│  │    14:35 - Confidence 94%│   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ 🏍️ 59X1-67890           │   │
│  │    14:20 - Confidence 91%│   │
│  └─────────────────────────┘   │
│                                 │
│  ─────────────────────────────  │
│  Hôm qua                        │
│  ─────────────────────────────  │
│  ┌─────────────────────────┐   │
│  │ 🚗 51G-11111            │   │
│  │    09:15 - Confidence 88%│   │
│  └─────────────────────────┘   │
│                                 │
│  Tổng: 3 biển số đã quét       │
└─────────────────────────────────┘
```

#### 4.2.6 Settings Screen

```
┌─────────────────────────────────┐
│ ←  Cài đặt                      │
├─────────────────────────────────┤
│                                 │
│  QUÉT                           │
│  ┌─────────────────────────┐   │
│  │ Confidence threshold    │   │
│  │ [────────●──────] 80%   │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ Tự động quét liên tục   │   │
│  │                    [ON] │   │
│  └─────────────────────────┘   │
│                                 │
│  PHẢN HỒI                       │
│  ┌─────────────────────────┐   │
│  │ Âm thanh           [ON] │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ Rung                [ON]│   │
│  └─────────────────────────┘   │
│                                 │
│  THÔNG TIN                      │
│  ┌─────────────────────────┐   │
│  │ Phiên bản        v1.0.0 │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ Về PlateSnap        →   │   │
│  └─────────────────────────┘   │
│                                 │
└─────────────────────────────────┘
```

### 4.3 Design System

#### Colors

```
Primary:          #2196F3 (Blue)
Primary Dark:     #1976D2
Primary Light:    #BBDEFB

Success:          #4CAF50 (Green) - Detection success
Error:            #F44336 (Red) - Detection failed
Warning:          #FF9800 (Orange)

Background:       #FFFFFF
Surface:          #F5F5F5
Card:             #FFFFFF

Text Primary:     #212121
Text Secondary:   #757575
Text Hint:        #BDBDBD

Plate Text:       #1A237E (Dark Blue) - Biển số
Bounding Box:     #4CAF50 (Green) - Detection box
Guide Frame:      #FFFFFF (White) với opacity 80%
```

#### Typography

```
Font Family: 
  - Android: Roboto
  - iOS: SF Pro

Plate Number:     32sp, Bold, Monospace (RobotoMono/SF Mono)
Heading 1:        24sp, Bold
Heading 2:        20sp, SemiBold  
Body:             16sp, Regular
Caption:          14sp, Regular
Button:           16sp, SemiBold, UPPERCASE
```

#### Spacing & Sizing

```
Base unit:        8dp
Screen padding:   16dp
Card padding:     16dp
Card radius:      12dp
Button height:    48dp
Button radius:    8dp
Icon size:        24dp
```

---

## 5. 🔧 Technical Architecture

### 5.1 System Architecture (Phase 1)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PlateSnap Mobile App (Flutter)                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   ┌────────────────────────────────────────────────────────────┐   │
│   │                    Presentation Layer                       │   │
│   │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │   │
│   │  │  Splash  │  │   Scan   │  │ History  │  │ Settings │   │   │
│   │  │  Screen  │  │  Screen  │  │  Screen  │  │  Screen  │   │   │
│   │  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │   │
│   └────────────────────────────────────────────────────────────┘   │
│                              │                                       │
│   ┌────────────────────────────────────────────────────────────┐   │
│   │                    Business Logic Layer                     │   │
│   │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │   │
│   │  │ ScanProvider │  │HistoryProvider│ │ SettingsProvider │  │   │
│   │  └──────────────┘  └──────────────┘  └──────────────────┘  │   │
│   └────────────────────────────────────────────────────────────┘   │
│                              │                                       │
│   ┌────────────────────────────────────────────────────────────┐   │
│   │                      Service Layer                          │   │
│   │  ┌─────────────────────────────────────────────────────┐   │   │
│   │  │                  OCR Service                         │   │   │
│   │  │  ┌─────────────┐         ┌─────────────────────┐    │   │   │
│   │  │  │   YOLOv8    │────────▶│    PaddleOCR /      │    │   │   │
│   │  │  │   TFLite    │         │    ML Kit Text      │    │   │   │
│   │  │  │  (Detect)   │         │    (Recognize)      │    │   │   │
│   │  │  └─────────────┘         └─────────────────────┘    │   │   │
│   │  └─────────────────────────────────────────────────────┘   │   │
│   │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │   │
│   │  │CameraService │  │ StorageService│ │  AudioService    │  │   │
│   │  └──────────────┘  └──────────────┘  └──────────────────┘  │   │
│   └────────────────────────────────────────────────────────────┘   │
│                              │                                       │
│   ┌────────────────────────────────────────────────────────────┐   │
│   │                       Data Layer                            │   │
│   │  ┌──────────────┐  ┌──────────────┐                        │   │
│   │  │ Local SQLite │  │SharedPrefs   │                        │   │
│   │  │ (History)    │  │(Settings)    │                        │   │
│   │  └──────────────┘  └──────────────┘                        │   │
│   └────────────────────────────────────────────────────────────┘   │
│                                                                      │
├─────────────────────────────────────────────────────────────────────┤
│                         Assets (Bundled)                             │
│  ┌──────────────────┐  ┌──────────────────┐                         │
│  │ yolov8n_plate    │  │ paddleocr_rec    │                         │
│  │ .tflite (~6MB)   │  │ .nb (~4MB)       │                         │
│  └──────────────────┘  └──────────────────┘                         │
└─────────────────────────────────────────────────────────────────────┘
```

### 5.2 OCR Pipeline Detail

```
┌─────────────────────────────────────────────────────────────────────┐
│                        OCR Processing Pipeline                       │
└─────────────────────────────────────────────────────────────────────┘

     ┌──────────┐
     │  Camera  │
     │  Frame   │
     │(1920x1080)│
     └────┬─────┘
          │
          ▼
     ┌──────────┐
     │ Resize   │
     │ 640x640  │
     │ (RGB)    │
     └────┬─────┘
          │
          ▼
┌─────────────────────┐
│  YOLOv8 Detection   │
│  ─────────────────  │
│  Input: 640x640x3   │
│  Output: [N, 6]     │
│  (x,y,w,h,conf,cls) │
└─────────┬───────────┘
          │
          ▼
     ┌──────────┐       ┌─────────────────────┐
     │ Filter   │──────▶│ No plate detected   │
     │ conf<0.5 │ No    │ Continue scanning   │
     └────┬─────┘       └─────────────────────┘
          │ Yes
          ▼
     ┌──────────┐
     │  Crop    │
     │  Plate   │
     │  Region  │
     └────┬─────┘
          │
          ▼
┌─────────────────────┐
│    Preprocess       │
│  ─────────────────  │
│  - Resize h=48      │
│  - Grayscale        │
│  - Normalize        │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  PaddleOCR / MLKit  │
│  ─────────────────  │
│  Text Recognition   │
│  Output: String     │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│   Post-process      │
│  ─────────────────  │
│  - Remove spaces    │
│  - Format: XX-XXXXX │
│  - Validate pattern │
└─────────┬───────────┘
          │
          ▼
     ┌──────────┐
     │  Result  │
     │"59A-12345"│
     │ conf: 94%│
     └──────────┘
```

### 5.3 Technology Stack (Phase 1)

| Component | Technology | Version | Notes |
|-----------|------------|---------|-------|
| **Framework** | Flutter | 3.16+ | Cross-platform |
| **Language** | Dart | 3.2+ | Null safety |
| **Camera** | camera | ^0.10.5 | Official plugin |
| **ML Runtime** | tflite_flutter | ^0.10.4 | TensorFlow Lite |
| **OCR Option 1** | google_mlkit_text_recognition | ^0.11.0 | Google ML Kit |
| **OCR Option 2** | paddle_lite | Custom | PaddleOCR |
| **State Mgmt** | provider | ^6.1.1 | Simple, effective |
| **Local DB** | sqflite | ^2.3.0 | History storage |
| **Storage** | shared_preferences | ^2.2.2 | Settings |
| **Clipboard** | flutter/services | Built-in | Copy function |
| **Audio** | audioplayers | ^5.2.1 | Beep sound |
| **Haptic** | flutter/services | Built-in | Vibration |

### 5.4 Model Files

| Model | Format | Size | Source |
|-------|--------|------|--------|
| YOLOv8n (plate detection) | .tflite | ~6MB | Train custom hoặc download |
| PaddleOCR-v3 (recognition) | .nb | ~4MB | PaddlePaddle |
| **Alternative:** ML Kit | On-device | ~10MB | Google (auto-download) |

---

## 6. 📁 Project Structure

```
platesnap/
├── android/
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml
│   │   │   └── kotlin/...
│   │   └── build.gradle
│   └── build.gradle
│
├── ios/
│   ├── Runner/
│   │   ├── Info.plist
│   │   └── AppDelegate.swift
│   └── Podfile
│
├── lib/
│   ├── main.dart                      # Entry point
│   │
│   ├── app/
│   │   ├── app.dart                   # MaterialApp config
│   │   ├── routes.dart                # Route definitions
│   │   └── theme.dart                 # Theme data
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart     # App-wide constants
│   │   │   ├── colors.dart            # Color definitions
│   │   │   └── strings.dart           # String constants
│   │   ├── utils/
│   │   │   ├── plate_formatter.dart   # Format biển số
│   │   │   ├── plate_validator.dart   # Validate pattern
│   │   │   └── image_utils.dart       # Image processing
│   │   └── extensions/
│   │       └── string_extensions.dart
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── scan_result.dart       # Scan result model
│   │   │   ├── detection_box.dart     # Bounding box model
│   │   │   └── settings.dart          # Settings model
│   │   ├── repositories/
│   │   │   ├── history_repository.dart
│   │   │   └── settings_repository.dart
│   │   └── datasources/
│   │       ├── local_database.dart    # SQLite
│   │       └── preferences.dart       # SharedPrefs
│   │
│   ├── services/
│   │   ├── ocr/
│   │   │   ├── ocr_service.dart       # Main OCR orchestrator
│   │   │   ├── plate_detector.dart    # YOLOv8 TFLite
│   │   │   ├── text_recognizer.dart   # PaddleOCR/MLKit
│   │   │   └── models/
│   │   │       └── ocr_result.dart
│   │   ├── camera_service.dart        # Camera management
│   │   ├── audio_service.dart         # Sound effects
│   │   └── haptic_service.dart        # Vibration
│   │
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── scan_provider.dart     # Scan state management
│   │   │   ├── history_provider.dart  # History state
│   │   │   └── settings_provider.dart # Settings state
│   │   ├── screens/
│   │   │   ├── splash/
│   │   │   │   └── splash_screen.dart
│   │   │   ├── scan/
│   │   │   │   ├── scan_screen.dart   # Main scan screen
│   │   │   │   ├── camera_preview.dart
│   │   │   │   ├── detection_overlay.dart
│   │   │   │   └── result_bottom_sheet.dart
│   │   │   ├── history/
│   │   │   │   ├── history_screen.dart
│   │   │   │   └── history_item.dart
│   │   │   └── settings/
│   │   │       └── settings_screen.dart
│   │   └── widgets/
│   │       ├── guide_frame.dart       # Camera guide overlay
│   │       ├── plate_display.dart     # Styled plate number
│   │       ├── confidence_badge.dart  # Confidence indicator
│   │       └── action_button.dart     # Styled buttons
│   │
│   └── di/
│       └── injection.dart             # Dependency injection
│
├── assets/
│   ├── models/
│   │   ├── yolov8n_plate.tflite      # Detection model
│   │   └── ppocr_rec.nb              # Recognition model
│   ├── sounds/
│   │   └── beep.mp3                  # Success sound
│   └── images/
│       ├── logo.png
│       └── placeholder.png
│
├── test/
│   ├── unit/
│   │   ├── plate_formatter_test.dart
│   │   └── plate_validator_test.dart
│   ├── widget/
│   │   └── scan_screen_test.dart
│   └── integration/
│       └── ocr_pipeline_test.dart
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## 7. 💻 Implementation Guide

### 7.1 Key Code Components

#### 7.1.1 OCR Service Interface

```dart
// lib/services/ocr/ocr_service.dart

import 'dart:typed_data';
import 'package:camera/camera.dart';

class OcrResult {
  final String plateNumber;
  final double confidence;
  final Rect boundingBox;
  final String vehicleType; // 'car' | 'motorbike'
  final DateTime timestamp;

  OcrResult({
    required this.plateNumber,
    required this.confidence,
    required this.boundingBox,
    required this.vehicleType,
    required this.timestamp,
  });
}

abstract class OcrService {
  Future<void> initialize();
  Future<OcrResult?> processFrame(CameraImage image);
  Future<OcrResult?> processImage(Uint8List imageBytes);
  void dispose();
}
```

#### 7.1.2 Plate Detector (YOLOv8)

```dart
// lib/services/ocr/plate_detector.dart

import 'package:tflite_flutter/tflite_flutter.dart';

class PlateDetector {
  late Interpreter _interpreter;
  static const int inputSize = 640;
  static const double confidenceThreshold = 0.5;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/models/yolov8n_plate.tflite');
  }

  List<DetectionResult> detect(Uint8List imageBytes) {
    // 1. Preprocess image to 640x640
    // 2. Run inference
    // 3. Post-process: NMS, filter by confidence
    // 4. Return list of DetectionResult
  }

  void dispose() {
    _interpreter.close();
  }
}

class DetectionResult {
  final Rect boundingBox;
  final double confidence;
  
  DetectionResult({required this.boundingBox, required this.confidence});
}
```

#### 7.1.3 Text Recognizer (ML Kit Option)

```dart
// lib/services/ocr/text_recognizer.dart

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class PlateTextRecognizer {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String?> recognize(Uint8List croppedPlate) async {
    final inputImage = InputImage.fromBytes(
      bytes: croppedPlate,
      metadata: InputImageMetadata(...),
    );
    
    final result = await _textRecognizer.processImage(inputImage);
    
    // Post-process: format plate number
    return _formatPlateNumber(result.text);
  }

  String? _formatPlateNumber(String rawText) {
    // Remove spaces, validate Vietnam plate pattern
    // Return formatted: "59A-12345"
  }

  void dispose() {
    _textRecognizer.close();
  }
}
```

#### 7.1.4 Plate Formatter & Validator

```dart
// lib/core/utils/plate_formatter.dart

class PlateFormatter {
  /// Format raw OCR text to standard Vietnam plate format
  /// Input: "59A 12345" or "59A12345" or "59 A 123.45"
  /// Output: "59A-12345"
  static String format(String raw) {
    // Remove all non-alphanumeric
    String cleaned = raw.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    
    // Try to match Vietnam plate patterns
    // Car: 51G12345 -> 51G-12345
    // Motorbike: 59X112345 -> 59X1-12345
    
    final carPattern = RegExp(r'^(\d{2})([A-Z])(\d{5})$');
    final motorbikePattern = RegExp(r'^(\d{2})([A-Z]\d)(\d{5})$');
    
    if (carPattern.hasMatch(cleaned)) {
      final match = carPattern.firstMatch(cleaned)!;
      return '${match.group(1)}${match.group(2)}-${match.group(3)}';
    }
    
    if (motorbikePattern.hasMatch(cleaned)) {
      final match = motorbikePattern.firstMatch(cleaned)!;
      return '${match.group(1)}${match.group(2)}-${match.group(3)}';
    }
    
    return cleaned; // Return as-is if no pattern match
  }
}

// lib/core/utils/plate_validator.dart

class PlateValidator {
  static const _vietnamPlatePattern = 
    r'^[0-9]{2}[A-Z]{1,2}[0-9]?-[0-9]{4,5}$';
    
  static bool isValid(String plate) {
    return RegExp(_vietnamPlatePattern).hasMatch(plate);
  }
  
  static String? getVehicleType(String plate) {
    if (RegExp(r'^[0-9]{2}[A-Z]-').hasMatch(plate)) return 'car';
    if (RegExp(r'^[0-9]{2}[A-Z][0-9]-').hasMatch(plate)) return 'motorbike';
    return null;
  }
}
```

#### 7.1.5 Scan Screen Widget

```dart
// lib/presentation/screens/scan/scan_screen.dart

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late CameraController _cameraController;
  late OcrService _ocrService;
  bool _isProcessing = false;
  OcrResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeOcr();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController.initialize();
    _startImageStream();
  }

  void _startImageStream() {
    _cameraController.startImageStream((CameraImage image) {
      if (!_isProcessing) {
        _processFrame(image);
      }
    });
  }

  Future<void> _processFrame(CameraImage image) async {
    _isProcessing = true;
    
    final result = await _ocrService.processFrame(image);
    
    if (result != null && result.confidence > 0.8) {
      setState(() => _lastResult = result);
      _showResultSheet(result);
      
      // Play sound & haptic
      await _playSuccessSound();
      await HapticFeedback.mediumImpact();
    }
    
    _isProcessing = false;
  }

  void _showResultSheet(OcrResult result) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ResultBottomSheet(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          CameraPreview(controller: _cameraController),
          
          // Guide Frame Overlay
          GuideFrameOverlay(),
          
          // Detection Box (if detecting)
          if (_lastResult != null)
            DetectionBoxOverlay(box: _lastResult!.boundingBox),
          
          // Top Bar
          SafeArea(
            child: TopBar(
              onSettingsTap: () => _openSettings(),
              onHistoryTap: () => _openHistory(),
            ),
          ),
          
          // Bottom Controls
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: BottomControls(
              onFlashTap: () => _toggleFlash(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _ocrService.dispose();
    super.dispose();
  }
}
```

### 7.2 Dependencies (pubspec.yaml)

```yaml
name: platesnap
description: License Plate Scanner App
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Camera
  camera: ^0.10.5+9
  
  # ML / OCR
  tflite_flutter: ^0.10.4
  google_mlkit_text_recognition: ^0.11.0
  
  # State Management
  provider: ^6.1.1
  
  # Local Storage
  sqflite: ^2.3.0
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  
  # UI
  flutter_svg: ^2.0.9
  
  # Utils
  permission_handler: ^11.1.0
  audioplayers: ^5.2.1
  intl: ^0.18.1
  uuid: ^4.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.4
  build_runner: ^2.4.7

flutter:
  uses-material-design: true
  
  assets:
    - assets/models/
    - assets/sounds/
    - assets/images/
```

---

## 8. 🧪 Testing Plan (Phase 1)

### 8.1 Unit Tests

| Test Case | Description | Expected |
|-----------|-------------|----------|
| PlateFormatter.format("59A12345") | Format car plate | "59A-12345" |
| PlateFormatter.format("59X167890") | Format motorbike plate | "59X1-67890" |
| PlateValidator.isValid("59A-12345") | Valid car plate | true |
| PlateValidator.isValid("ABC-12345") | Invalid province code | false |
| PlateValidator.getVehicleType("59A-12345") | Get vehicle type | "car" |

### 8.2 OCR Accuracy Test

**Test Dataset:**
- 100 ảnh biển số xe máy (1 dòng)
- 100 ảnh biển số xe máy (2 dòng)
- 100 ảnh biển số ô tô
- Điều kiện đa dạng: sáng/tối, góc nghiêng, sạch/bẩn

**Metrics:**
| Metric | Target | Measurement |
|--------|--------|-------------|
| Detection Rate | ≥ 95% | Detect được biển số / Tổng ảnh |
| OCR Accuracy | ≥ 90% | Đọc đúng / Detect đúng |
| End-to-end Accuracy | ≥ 85% | Đọc đúng / Tổng ảnh |

### 8.3 Performance Test

| Metric | Target | Tool |
|--------|--------|------|
| Detection latency | < 100ms | Stopwatch |
| OCR latency | < 400ms | Stopwatch |
| Total pipeline | < 500ms | Stopwatch |
| Memory usage | < 200MB | Flutter DevTools |
| Battery drain | < 5%/hour | Battery monitor |

### 8.4 Device Test Matrix

| Device | OS Version | Status |
|--------|------------|--------|
| Samsung Galaxy A52 | Android 12 | Required |
| Xiaomi Redmi Note 11 | Android 11 | Required |
| iPhone 12 | iOS 15 | Required |
| iPhone SE (2020) | iOS 14 | Required |
| Low-end Android (2GB RAM) | Android 9 | Nice to have |

---

## 9. 📅 Development Timeline (Phase 1)

### Sprint Plan (2 weeks)

```
Week 1: Core Development
├── Day 1-2: Project Setup
│   ├── Flutter project initialization
│   ├── Folder structure
│   ├── Dependencies setup
│   └── Theme & constants
│
├── Day 3-4: Camera Module
│   ├── Camera permission
│   ├── Camera preview
│   ├── Guide frame overlay
│   └── Flash toggle
│
└── Day 5-7: OCR Integration
    ├── YOLOv8 TFLite integration
    ├── ML Kit / PaddleOCR integration
    ├── Pipeline connection
    └── Result formatting

Week 2: Features & Polish
├── Day 8-9: UI/UX
│   ├── Result bottom sheet
│   ├── Copy to clipboard
│   ├── Sound & haptic feedback
│   └── Polish animations
│
├── Day 10-11: History & Settings
│   ├── Local database setup
│   ├── History screen
│   ├── Settings screen
│   └── Preferences storage
│
├── Day 12-13: Testing & Fixes
│   ├── Unit tests
│   ├── OCR accuracy testing
│   ├── Bug fixes
│   └── Performance optimization
│
└── Day 14: Release Prep
    ├── App icons
    ├── Splash screen
    ├── Build APK/IPA
    └── Documentation
```

### Milestones

| Milestone | Date | Deliverable |
|-----------|------|-------------|
| M1: Camera Works | Day 4 | Camera preview với guide frame |
| M2: OCR Works | Day 7 | Quét được biển số, hiển thị text |
| M3: Feature Complete | Day 11 | History, Settings hoạt động |
| M4: Release Ready | Day 14 | APK + IPA ready for testing |

---

## 10. 📦 Deliverables (Phase 1)

### 10.1 Source Code

- [ ] Flutter project với full source code
- [ ] README.md với hướng dẫn setup
- [ ] Unit tests

### 10.2 Build Artifacts

- [ ] Android APK (debug + release)
- [ ] iOS IPA (TestFlight ready)

### 10.3 Documentation

- [ ] Technical documentation
- [ ] API documentation (cho OCR service)
- [ ] User guide (ngắn gọn)

### 10.4 Assets

- [ ] App icon (Android + iOS)
- [ ] Splash screen
- [ ] ML models (TFLite, PaddleLite)

---

## 11. 🚀 Phase 2 Preview (Future)

Sau khi Phase 1 hoàn thành, Phase 2 sẽ bao gồm:

| Feature | Description |
|---------|-------------|
| Backend API | Node.js + PostgreSQL |
| Vehicle Database | Lưu thông tin xe + chủ |
| Lookup Integration | Sau OCR → gọi API tra cứu |
| Owner Info Display | Hiển thị tên, căn hộ, SĐT |
| Call Action | Tap để gọi chủ xe |
| Admin Panel | Web dashboard quản lý |
| Multi-building | Hỗ trợ nhiều chung cư |

---

## 12. ✅ Acceptance Criteria (Phase 1)

### Must Have (P0)

- [ ] App chạy được trên Android 8+ và iOS 13+
- [ ] Mở camera và hiển thị preview
- [ ] Có khung hướng dẫn quét
- [ ] Detect được vùng biển số (bounding box)
- [ ] Đọc được text biển số với accuracy ≥ 85%
- [ ] Hiển thị kết quả biển số
- [ ] Copy biển số vào clipboard
- [ ] Quét lại (reset)
- [ ] Hoạt động offline (OCR on-device)

### Should Have (P1)

- [ ] Lịch sử quét (local)
- [ ] Flash toggle
- [ ] Settings cơ bản
- [ ] Sound/haptic feedback

### Nice to Have (P2)

- [ ] Zoom camera
- [ ] Export history
- [ ] Dark mode

---

## 📝 Appendix

### A. Vietnam License Plate Patterns

```
Xe ô tô (Car):
─────────────────
Format: [2 số tỉnh][1 chữ cái]-[5 số]
Example: 51G-12345, 30A-99999

Xe máy (Motorbike):
─────────────────
Format: [2 số tỉnh][1 chữ + 1 số]-[5 số]
Example: 59X1-12345, 29B1-67890

Biển 2 dòng (xe máy cũ):
─────────────────
Dòng 1: 59-X1
Dòng 2: 123.45

Mã tỉnh phổ biến:
─────────────────
29, 30, 31, 32, 33: Hà Nội
41, 50-59: Hồ Chí Minh
43: Đà Nẵng
92: Quảng Nam
```

### B. Regex Patterns

```dart
// Car plate: 51G-12345
final carPlate = RegExp(r'^[0-9]{2}[A-Z]-[0-9]{5}$');

// Motorbike plate: 59X1-12345
final motorbikePlate = RegExp(r'^[0-9]{2}[A-Z][0-9]-[0-9]{5}$');

// Generic Vietnam plate
final vietnamPlate = RegExp(r'^[0-9]{2}[A-Z]{1,2}[0-9]?-[0-9]{4,5}$');
```

### C. Error Codes

| Code | Message | Action |
|------|---------|--------|
| CAM_001 | Camera permission denied | Hiển thị hướng dẫn cấp quyền |
| CAM_002 | Camera not available | Hiển thị error screen |
| OCR_001 | Model load failed | Retry hoặc báo lỗi |
| OCR_002 | Detection timeout | Retry |
| OCR_003 | Recognition failed | Hiển thị "Không đọc được" |

---

**Document Version History:**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 07/01/2026 | AI Assistant | Initial Phase 1 focused document |

---

*Tài liệu này tập trung vào Phase 1 - xây dựng app OCR biển số xe. Phase 2+ sẽ được document riêng sau khi Phase 1 hoàn thành.*

---

## 🎯 Quick Start for AI Agent

```
Project: PlateSnap
Platform: Flutter (Android + iOS)
Focus: On-device license plate OCR

Key Tasks:
1. Setup Flutter project với camera
2. Integrate YOLOv8 TFLite cho plate detection
3. Integrate ML Kit / PaddleOCR cho text recognition
4. Build UI: Scan screen + Result + History
5. Local storage cho history

Models needed:
- yolov8n_plate.tflite (plate detection)
- ML Kit Text Recognition (built-in) hoặc PaddleOCR .nb

Output: 
- Biển số dạng text: "59A-12345"
- Confidence score
- Vehicle type (car/motorbike)
```
