import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/constants/colors.dart';

class PlateDisplay extends StatelessWidget {
  final String plateNumber;
  final double fontSize;
  final bool showBorder;
  final Color? backgroundColor;
  final Color? textColor;

  const PlateDisplay({
    super.key,
    required this.plateNumber,
    this.fontSize = 32,
    this.showBorder = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: showBorder
            ? Border.all(color: AppColors.textSecondary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _formatPlateForDisplay(plateNumber),
        style: AppTheme.plateNumberStyle.copyWith(
          fontSize: fontSize,
          color: textColor ?? AppColors.plateText,
        ),
      ),
    );
  }

  String _formatPlateForDisplay(String plate) {
    if (plate.contains('-')) {
      return plate.replaceAll('-', ' - ');
    }
    return plate;
  }
}

class PlateDisplayCompact extends StatelessWidget {
  final String plateNumber;
  final String? vehicleType;
  final VoidCallback? onTap;

  const PlateDisplayCompact({
    super.key,
    required this.plateNumber,
    this.vehicleType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (vehicleType != null) ...[
              Icon(
                vehicleType == 'car' ? Icons.directions_car : Icons.two_wheeler,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              plateNumber,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                color: AppColors.plateText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
