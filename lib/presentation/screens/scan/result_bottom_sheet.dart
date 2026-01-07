import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../services/ocr/models/ocr_result.dart';
import '../../widgets/plate_display.dart';
import '../../widgets/confidence_badge.dart';
import '../../widgets/action_button.dart';

class ResultBottomSheet extends StatelessWidget {
  final OcrResult result;
  final VoidCallback? onScanAgain;
  final VoidCallback? onClose;

  const ResultBottomSheet({
    super.key,
    required this.result,
    this.onScanAgain,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textHint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Success icon
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),

          // Success message
          const Text(
            AppStrings.success,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // Plate number display
          PlateDisplay(plateNumber: result.plateNumber),
          const SizedBox(height: 16),

          // Details row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConfidenceBadge(confidence: result.confidence),
              const SizedBox(width: 16),
              _VehicleTypeBadge(vehicleType: result.vehicleType),
            ],
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: AppStrings.copy.toUpperCase(),
                  icon: Icons.copy,
                  isPrimary: true,
                  onPressed: () => _copyToClipboard(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ActionButton(
                  label: AppStrings.scanAgain.toUpperCase(),
                  icon: Icons.refresh,
                  isPrimary: false,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onScanAgain?.call();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Timestamp
          Text(
            '${AppStrings.scannedAt}: ${DateFormat('dd/MM/yyyy HH:mm').format(result.timestamp)}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: result.plateNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.copied),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _VehicleTypeBadge extends StatelessWidget {
  final String vehicleType;

  const _VehicleTypeBadge({required this.vehicleType});

  @override
  Widget build(BuildContext context) {
    final icon = vehicleType == 'car' ? Icons.directions_car : Icons.two_wheeler;
    final label = vehicleType == 'car' ? AppStrings.car : AppStrings.motorbike;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

void showResultBottomSheet(
  BuildContext context, {
  required OcrResult result,
  VoidCallback? onScanAgain,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ResultBottomSheet(
      result: result,
      onScanAgain: onScanAgain,
    ),
  );
}
