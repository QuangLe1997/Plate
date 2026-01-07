import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
      backgroundColor: Colors.white,
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
    debugPrint('=== Opening detail sheet for: ${result.plateNumber}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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

  Future<void> _makePhoneCall(BuildContext context) async {
    debugPrint('=== _makePhoneCall: ownerPhone = ${result.ownerPhone}');

    if (result.ownerPhone == null || result.ownerPhone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khong co so dien thoai')),
      );
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: result.ownerPhone);
    debugPrint('=== Calling: $phoneUri');

    try {
      final launched = await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );
      debugPrint('=== Launch result: $launched');
    } catch (e) {
      debugPrint('=== Call error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loi khi goi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Plate number
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Text(
                result.plateNumber,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Owner info section
            if (result.hasOwnerInfo) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(Icons.person, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'THONG TIN CHU XE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Owner name
                    Text(
                      result.ownerName ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (result.ownerGender != null || result.ownerAge != null)
                      Text(
                        '${result.ownerGender ?? ''} ${result.ownerAge != null ? "- ${result.ownerAge} tuoi" : ""}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    if (result.ownerPhone != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.phone, size: 18, color: AppColors.success),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                result.ownerPhone!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (result.ownerAddress != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, size: 18, color: Colors.red[400]),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                result.ownerAddress!,
                                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

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

            // Buttons row
            Row(
              children: [
                // Copy button
                Expanded(
                  child: OutlinedButton.icon(
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
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.copy),
                    label: const Text(AppStrings.copy),
                  ),
                ),
                // Call button (if has phone)
                if (result.ownerPhone != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _makePhoneCall(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.call),
                      label: const Text('Goi ngay'),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
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
