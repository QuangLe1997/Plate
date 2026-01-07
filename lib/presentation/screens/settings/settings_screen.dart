import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Scanning section
              _SectionHeader(title: AppStrings.scanning),
              _SettingsCard(
                children: [
                  _SliderSetting(
                    title: AppStrings.confidenceThreshold,
                    value: provider.confidenceThreshold,
                    min: 0.5,
                    max: 0.95,
                    displayValue: '${provider.confidenceThresholdPercent}%',
                    onChanged: (value) => provider.setConfidenceThreshold(value),
                  ),
                  const Divider(),
                  _SwitchSetting(
                    title: AppStrings.autoContinuousScan,
                    value: provider.autoContinuousScan,
                    onChanged: (value) => provider.setAutoContinuousScan(value),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Feedback section
              _SectionHeader(title: AppStrings.feedback),
              _SettingsCard(
                children: [
                  _SwitchSetting(
                    title: AppStrings.sound,
                    value: provider.soundEnabled,
                    icon: Icons.volume_up,
                    onChanged: (value) => provider.setSoundEnabled(value),
                  ),
                  const Divider(),
                  _SwitchSetting(
                    title: AppStrings.vibration,
                    value: provider.vibrationEnabled,
                    icon: Icons.vibration,
                    onChanged: (value) => provider.setVibrationEnabled(value),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Information section
              _SectionHeader(title: AppStrings.information),
              _SettingsCard(
                children: [
                  _InfoSetting(
                    title: AppStrings.appVersion,
                    value: AppStrings.version,
                    icon: Icons.info_outline,
                  ),
                  const Divider(),
                  _NavigationSetting(
                    title: AppStrings.about,
                    icon: Icons.help_outline,
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Reset button
              Center(
                child: TextButton(
                  onPressed: () => _showResetDialog(context, provider),
                  child: const Text(
                    'Khoi phuc mac dinh',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.document_scanner, color: AppColors.primary),
            SizedBox(width: 8),
            Text(AppStrings.appName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.tagline,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ung dung nhan dien bien so xe Viet Nam bang cong nghe OCR tren thiet bi. '
              'Hoat dong hoan toan offline, khong can ket noi internet.',
            ),
            const SizedBox(height: 16),
            Text(
              'Phien ban: ${AppStrings.version}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Dong'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Khoi phuc cai dat'),
        content: const Text('Ban co chac muon khoi phuc tat ca cai dat ve mac dinh?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Huy'),
          ),
          TextButton(
            onPressed: () {
              provider.resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Da khoi phuc cai dat mac dinh'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Khoi phuc'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(children: children),
      ),
    );
  }
}

class _SwitchSetting extends StatelessWidget {
  final String title;
  final bool value;
  final IconData? icon;
  final ValueChanged<bool> onChanged;

  const _SwitchSetting({
    required this.title,
    required this.value,
    this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SliderSetting({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                displayValue,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 100).toInt(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _InfoSetting extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoSetting({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationSetting extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _NavigationSetting({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
