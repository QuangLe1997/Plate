import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/app.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../app/routes.dart';
import '../../../services/ocr/models/ocr_result.dart';
import '../../providers/scan_provider.dart';
import '../../widgets/guide_frame.dart';
import 'camera_preview.dart';
import 'result_bottom_sheet.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver, RouteAware {
  bool _isBottomSheetShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Set status bar style for full screen camera
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _initializeCamera();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to global route observer to detect navigation
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    // Stop scanning when screen is disposed
    context.read<ScanProvider>().pauseCamera();
    super.dispose();
  }

  // Called when this screen is no longer visible (pushed another screen on top)
  @override
  void didPushNext() {
    debugPrint('=== ScanScreen: didPushNext - PAUSING CAMERA');
    context.read<ScanProvider>().pauseCamera();
  }

  // Called when this screen becomes visible again (popped back from another screen)
  @override
  void didPopNext() async {
    debugPrint('=== ScanScreen: didPopNext - Resuming camera');
    final scanProvider = context.read<ScanProvider>();

    // Resume camera first (re-create controller)
    await scanProvider.resumeCamera();

    // Then start scanning if not in detected state
    if (scanProvider.state != ScanState.detected) {
      await scanProvider.startScanning();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final scanProvider = context.read<ScanProvider>();

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      debugPrint('=== App lifecycle: $state - PAUSING CAMERA');
      await scanProvider.pauseCamera();
    } else if (state == AppLifecycleState.resumed) {
      // Only resume if screen is currently visible and not showing result
      if (ModalRoute.of(context)?.isCurrent == true &&
          scanProvider.state != ScanState.detected) {
        debugPrint('=== App lifecycle: resumed - Resuming camera');
        await scanProvider.resumeCamera();
        await scanProvider.startScanning();
      }
    }
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();

    if (!mounted) return;

    if (status.isGranted) {
      final scanProvider = context.read<ScanProvider>();
      await scanProvider.initialize();

      if (scanProvider.state != ScanState.error) {
        await scanProvider.startScanning();
      }
    } else {
      _showPermissionDeniedDialog();
    }
  }

  void _showTestResult(BuildContext context) async {
    // PAUSE camera completely when showing result
    final scanProvider = context.read<ScanProvider>();
    debugPrint('=== TEST: Pausing camera...');
    await scanProvider.pauseCamera();

    // Create a fake OCR result for testing
    final testResult = OcrResult(
      plateNumber: '51G-12345',
      confidence: 0.95,
      boundingBox: Rect.zero,
      vehicleType: 'car',
    );

    if (!mounted) return;

    showResultBottomSheet(
      context,
      result: testResult,
      onScanAgain: () {
        scanProvider.resetScan();
        scanProvider.startScanning();
      },
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(AppStrings.cameraPermissionTitle),
        content: const Text(AppStrings.cameraPermissionMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text(AppStrings.openSettings),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ScanProvider>(
        builder: (context, scanProvider, child) {
          // Show result when detected (only once)
          if (scanProvider.state == ScanState.detected &&
              scanProvider.currentResult != null &&
              !_isBottomSheetShown) {
            _isBottomSheetShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;

              // Camera already stopped by scan_provider, but ensure it's paused
              debugPrint('=== DETECTED: Showing result bottom sheet');

              showResultBottomSheet(
                context,
                result: scanProvider.currentResult!,
                onScanAgain: () {
                  _isBottomSheetShown = false;
                  scanProvider.resetScan();
                  scanProvider.startScanning();
                  debugPrint('=== SCAN AGAIN: Camera resumed');
                },
              ).then((_) {
                // Reset flag when bottom sheet is dismissed
                _isBottomSheetShown = false;
                debugPrint('=== BOTTOM SHEET DISMISSED');
              });
            });
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // Full screen camera preview - only show when scanning
              if (scanProvider.state == ScanState.scanning)
                CameraPreviewWidget(
                  controller: scanProvider.cameraController,
                  overlay: const GuideFrameOverlay(),
                )
              else
                // Black background when camera is off
                Container(color: Colors.black),

              // Top bar with glassmorphism effect
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTopBar(context, scanProvider),
              ),

              // Bottom controls - only show when scanning or idle
              if (scanProvider.state == ScanState.scanning ||
                  scanProvider.state == ScanState.idle)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomControls(scanProvider),
                ),

              // Error overlay
              if (scanProvider.state == ScanState.error)
                _buildErrorOverlay(scanProvider),

              // Initializing overlay
              if (scanProvider.state == ScanState.initializing)
                _buildInitializingOverlay(),

              // Detected overlay - camera is OFF
              if (scanProvider.state == ScanState.detected)
                Container(
                  color: Colors.black.withOpacity(0.9),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Dang xu ly...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ScanProvider scanProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // App title with NextIA logo
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/nextia_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.appName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppStrings.companySlogan,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Action buttons
              Row(
                children: [
                  _buildIconButton(
                    icon: Icons.history_rounded,
                    onPressed: () async {
                      // PAUSE camera completely before navigating
                      debugPrint('=== NAV TO HISTORY: Pausing camera...');
                      await context.read<ScanProvider>().pauseCamera();
                      if (context.mounted) {
                        Navigator.of(context).pushNamed(AppRoutes.history);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    icon: Icons.settings_rounded,
                    onPressed: () async {
                      // PAUSE camera completely before navigating
                      debugPrint('=== NAV TO SETTINGS: Pausing camera...');
                      await context.read<ScanProvider>().pauseCamera();
                      if (context.mounted) {
                        Navigator.of(context).pushNamed(AppRoutes.settings);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(ScanProvider scanProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withAlpha(200),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Flash button
              _buildControlButton(
                icon: scanProvider.isFlashOn
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
                label: 'Den flash',
                isActive: scanProvider.isFlashOn,
                onPressed: () => scanProvider.toggleFlash(),
              ),

              const SizedBox(width: 32),

              // Main rescan button (long press for test)
              GestureDetector(
                onTap: () {
                  if (scanProvider.state != ScanState.scanning) {
                    scanProvider.resetScan();
                    scanProvider.startScanning();
                  }
                },
                onLongPress: () {
                  // Test: Show fake result
                  debugPrint('=== LONG PRESS: Showing test result');
                  _showTestResult(context);
                },
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scanProvider.state == ScanState.scanning
                        ? AppColors.primary.withAlpha(80)
                        : AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(100),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: scanProvider.state == ScanState.scanning
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                  ),
                ),
              ),

              const SizedBox(width: 32),

              // Placeholder for symmetry
              const SizedBox(width: 52),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.white.withOpacity(0.15),
              border: isActive
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorOverlay(ScanProvider scanProvider) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 56,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Khong the ket noi camera',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                scanProvider.errorMessage ?? AppStrings.errorCameraNotAvailable,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _initializeCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  'Thu lai',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitializingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Dang khoi dong camera...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui long cho trong giay lat',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
