import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/colors.dart';
import '../../../services/ocr/models/ocr_result.dart';
import '../../../data/models/vehicle_owner.dart';
import '../../../services/vehicle_owner_service.dart';

class ResultBottomSheet extends StatefulWidget {
  final OcrResult result;
  final VoidCallback? onScanAgain;

  const ResultBottomSheet({
    super.key,
    required this.result,
    this.onScanAgain,
  });

  @override
  State<ResultBottomSheet> createState() => _ResultBottomSheetState();
}

class _ResultBottomSheetState extends State<ResultBottomSheet> {
  VehicleOwner? _owner;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOwnerInfo();
  }

  Future<void> _fetchOwnerInfo() async {
    try {
      final owner = await VehicleOwnerService.fetchOwnerByPlate(
        widget.result.plateNumber,
      );
      if (mounted) {
        setState(() {
          _owner = owner;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _makePhoneCall() async {
    if (_owner == null) return;
    final Uri uri = Uri(scheme: 'tel', path: _owner!.phoneNumber);
    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Khong the goi: $e')),
        );
      }
    }
  }

  void _copyPlate() {
    Clipboard.setData(ClipboardData(text: widget.result.plateNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Da sao chep bien so'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Success icon and title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 48,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Nhan dien thanh cong!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // PLATE NUMBER - Main focus
          GestureDetector(
            onTap: _copyPlate,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7), // Light yellow
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      widget.result.plateNumber,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.copy, size: 20, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Do chinh xac: ${(widget.result.confidence * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // OWNER INFO SECTION
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildOwnerSection(),
            ),
          ),

          // BOTTOM BUTTONS
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Scan Again button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onScanAgain?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text(
                        'Quet lai',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Call button (if owner exists)
                  if (_owner != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _makePhoneCall,
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
                        label: const Text(
                          'Goi ngay',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerSection() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Column(
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(height: 16),
            Text(
              'Dang tai thong tin chu xe...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_owner == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(Icons.person_off, size: 40, color: Colors.orange),
            SizedBox(height: 8),
            Text(
              'Khong tim thay thong tin chu xe',
              style: TextStyle(color: Colors.orange),
            ),
          ],
        ),
      );
    }

    // OWNER INFO CARD
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Thong tin chu xe',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Owner Name - Big and prominent
          Text(
            _owner!.fullName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // Gender & Age
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _owner!.gender == 'Nam'
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.pink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _owner!.gender,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _owner!.gender == 'Nam' ? Colors.blue : Colors.pink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_owner!.age} tuoi',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Phone Number - Highlighted
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone, size: 18, color: AppColors.success),
                const SizedBox(width: 10),
                Text(
                  _formatPhone(_owner!.phoneNumber),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Address
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.red[400]),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _owner!.displayAddress,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Vehicle Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.directions_car, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  '${_owner!.vehicleBrand} - ${_owner!.vehicleColor}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPhone(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 4)} ${phone.substring(4, 7)} ${phone.substring(7)}';
    }
    return phone;
  }
}

// Helper function to show the bottom sheet
Future<void> showResultBottomSheet(
  BuildContext context, {
  required OcrResult result,
  VoidCallback? onScanAgain,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (context) => ResultBottomSheet(
      result: result,
      onScanAgain: onScanAgain,
    ),
  );
}
