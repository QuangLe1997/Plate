import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon),
        label: Text(label),
      );
    }

    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Icon(icon),
      label: Text(label),
    );
  }
}

class CircularActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;

  const CircularActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 56,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor ?? AppColors.textPrimary,
          size: size * 0.45,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

class FlashButton extends StatelessWidget {
  final bool isOn;
  final VoidCallback? onPressed;

  const FlashButton({
    super.key,
    required this.isOn,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CircularActionButton(
      icon: isOn ? Icons.flash_on : Icons.flash_off,
      onPressed: onPressed,
      backgroundColor: isOn ? AppColors.warning : Colors.white.withOpacity(0.9),
      iconColor: isOn ? Colors.white : AppColors.textPrimary,
      tooltip: isOn ? 'Tat den flash' : 'Bat den flash',
    );
  }
}
