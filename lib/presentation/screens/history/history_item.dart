import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/scan_result.dart';

class HistoryItem extends StatelessWidget {
  final ScanResult result;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;
  final VoidCallback? onCall;

  const HistoryItem({
    super.key,
    required this.result,
    this.onTap,
    this.onDelete,
    this.onCopy,
    this.onCall,
  });

  Future<void> _makePhoneCall(BuildContext context) async {
    if (result.ownerPhone == null) return;

    final Uri launchUri = Uri(scheme: 'tel', path: result.ownerPhone);
    try {
      await launchUrl(
        launchUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Khong the goi: $e')),
        );
      }
    }
  }

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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: plate + time
                Row(
                  children: [
                    // Vehicle icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        result.vehicleType == 'car'
                            ? Icons.directions_car
                            : Icons.two_wheeler,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Plate info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.plateNumber,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: AppColors.plateText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('HH:mm - dd/MM').format(result.scannedAt),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
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
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      tooltip: 'Sao chep',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ],
                ),

                // Owner info row (if available)
                if (result.hasOwnerInfo) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // Owner info
                        Icon(
                          Icons.person,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.ownerName ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (result.ownerAddress != null)
                                Text(
                                  result.ownerAddress!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),

                        // Call button
                        if (result.ownerPhone != null)
                          ElevatedButton.icon(
                            onPressed: () => _makePhoneCall(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: Size.zero,
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.call, size: 14),
                            label: const Text(
                              'Goi',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
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
