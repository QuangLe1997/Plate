import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class ConfidenceBadge extends StatelessWidget {
  final double confidence;
  final bool showLabel;
  final double size;

  const ConfidenceBadge({
    super.key,
    required this.confidence,
    this.showLabel = true,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (confidence * 100).toInt();
    final color = _getColor(confidence);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Text(
            'Do chinh xac: ',
            style: TextStyle(
              fontSize: size,
              color: AppColors.textSecondary,
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIcon(confidence),
                size: size,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: size,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getColor(double confidence) {
    if (confidence >= 0.9) {
      return AppColors.success;
    } else if (confidence >= 0.7) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  IconData _getIcon(double confidence) {
    if (confidence >= 0.9) {
      return Icons.check_circle;
    } else if (confidence >= 0.7) {
      return Icons.info;
    } else {
      return Icons.warning;
    }
  }
}

class ConfidenceProgressBar extends StatelessWidget {
  final double confidence;
  final double height;

  const ConfidenceProgressBar({
    super.key,
    required this.confidence,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(confidence);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: confidence,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }

  Color _getColor(double confidence) {
    if (confidence >= 0.9) {
      return AppColors.success;
    } else if (confidence >= 0.7) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}
