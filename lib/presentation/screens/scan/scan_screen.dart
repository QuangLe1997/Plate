import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../app/routes.dart';
import '../../providers/scan_provider.dart';
import '../../widgets/guide_frame.dart';
import '../../widgets/action_button.dart';
import 'camera_preview.dart';
import 'result_bottom_sheet.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final scanProvider = context.read<ScanProvider>();

    if (state == AppLifecycleState.inactive) {
      scanProvider.stopScanning();
    } else if (state == AppLifecycleState.resumed) {
      if (scanProvider.isCameraInitialized) {
        scanProvider.startScanning();
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

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
      body: Consumer<ScanProvider>(
        builder: (context, scanProvider, child) {
          // Show result when detected
          if (scanProvider.state == ScanState.detected &&
              scanProvider.currentResult != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showResultBottomSheet(
                context,
                result: scanProvider.currentResult!,
                onScanAgain: () {
                  scanProvider.resetScan();
                  scanProvider.startScanning();
                },
              );
            });
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // Camera preview
              CameraPreviewWidget(
                controller: scanProvider.cameraController,
                overlay: const GuideFrameOverlay(),
              ),

              // Top bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTopBar(context),
              ),

              // Status indicator
              Positioned(
                bottom: 120,
                left: 24,
                right: 24,
                child: _buildStatusIndicator(scanProvider),
              ),

              // Bottom controls
              Positioned(
                bottom: 32,
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // App title
            const Text(
              AppStrings.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            // Action buttons
            Row(
              children: [
                IconButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.settings),
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.history),
                  icon: const Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ScanProvider scanProvider) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (scanProvider.state) {
      case ScanState.scanning:
        statusText = AppStrings.detecting;
        statusColor = AppColors.primary;
        statusIcon = Icons.search;
        break;
      case ScanState.detected:
        statusText =
            '${AppStrings.detected}: ${scanProvider.currentResult?.plateNumber ?? ""}';
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case ScanState.error:
        statusText = scanProvider.errorMessage ?? AppStrings.errorOcrFailed;
        statusColor = AppColors.error;
        statusIcon = Icons.error;
        break;
      default:
        statusText = AppStrings.scanInstruction;
        statusColor = Colors.white;
        statusIcon = Icons.center_focus_weak;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(ScanProvider scanProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FlashButton(
          isOn: scanProvider.isFlashOn,
          onPressed: () => scanProvider.toggleFlash(),
        ),
      ],
    );
  }

  Widget _buildErrorOverlay(ScanProvider scanProvider) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                scanProvider.errorMessage ?? AppStrings.errorCameraNotAvailable,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initializeCamera,
                child: const Text('Thu lai'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitializingOverlay() {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Dang khoi tao camera...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
