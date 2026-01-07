import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../data/models/scan_result.dart';
import '../../providers/history_provider.dart';
import 'history_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.history),
        actions: [
          Consumer<HistoryProvider>(
            builder: (context, provider, child) {
              if (provider.history.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => _showClearAllDialog(context, provider),
                icon: const Icon(Icons.delete_outline),
                tooltip: AppStrings.clearAll,
              );
            },
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchPlate,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              provider.clearSearch();
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    provider.search(value);
                  },
                ),
              ),

              // History list
              Expanded(
                child: provider.history.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryList(provider),
              ),

              // Total count
              if (provider.history.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    AppStrings.totalScanned.replaceAll('%d', '${provider.totalCount}'),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.noHistory,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(HistoryProvider provider) {
    final groupedHistory = provider.groupedHistory;
    final sortedDates = groupedHistory.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final items = groupedHistory[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                provider.getDateLabel(date),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            // Items for this date
            ...items.map((item) => HistoryItem(
                  result: item,
                  onTap: () => _showDetailSheet(context, item),
                  onDelete: () => provider.deleteItem(item.id),
                  onCopy: () => _copyPlate(item.plateNumber),
                )),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  void _showDetailSheet(BuildContext context, ScanResult result) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _DetailBottomSheet(result: result),
    );
  }

  void _copyPlate(String plate) {
    Clipboard.setData(ClipboardData(text: plate));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.copied),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, HistoryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.clearAll),
        content: const Text(AppStrings.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Huy'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
  }
}

class _DetailBottomSheet extends StatelessWidget {
  final ScanResult result;

  const _DetailBottomSheet({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textHint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Plate number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textSecondary),
            ),
            child: Text(
              result.plateNumber,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: AppColors.plateText,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Details
          _DetailRow(
            label: AppStrings.vehicleType,
            value: result.vehicleTypeDisplay,
            icon: result.vehicleType == 'car'
                ? Icons.directions_car
                : Icons.two_wheeler,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: AppStrings.confidence,
            value: result.confidencePercent,
            icon: Icons.analytics,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: AppStrings.scannedAt,
            value: DateFormat('dd/MM/yyyy HH:mm').format(result.scannedAt),
            icon: Icons.access_time,
          ),
          const SizedBox(height: 24),

          // Copy button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: result.plateNumber));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.copied),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text(AppStrings.copy),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
