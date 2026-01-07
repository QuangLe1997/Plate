import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/scan_result.dart';

class HistoryItem extends StatelessWidget {
  final ScanResult result;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;

  const HistoryItem({
    super.key,
    required this.result,
    this.onTap,
    this.onDelete,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(result.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Vehicle icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    result.vehicleType == 'car'
                        ? Icons.directions_car
                        : Icons.two_wheeler,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),

                // Plate info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.plateNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: AppColors.plateText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('HH:mm').format(result.scannedAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _ConfidenceIndicator(confidence: result.confidence),
                        ],
                      ),
                    ],
                  ),
                ),

                // Copy button
                IconButton(
                  onPressed: onCopy,
                  icon: const Icon(
                    Icons.copy,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Sao chep',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfidenceIndicator extends StatelessWidget {
  final double confidence;

  const _ConfidenceIndicator({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percent = (confidence * 100).toInt();
    final color = _getColor();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$percent%',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getColor() {
    if (confidence >= 0.9) {
      return AppColors.success;
    } else if (confidence >= 0.7) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}
