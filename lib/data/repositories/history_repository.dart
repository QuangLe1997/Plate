import '../datasources/local_database.dart';
import '../models/scan_result.dart';
import '../../core/constants/app_constants.dart';

class HistoryRepository {
  // Add scan result to history
  Future<void> addScanResult(ScanResult result) async {
    await LocalDatabase.insertScanResult(result);

    // Auto cleanup to keep only max records
    await LocalDatabase.keepLatestRecords(AppConstants.maxHistoryRecords);
  }

  // Get all scan history
  Future<List<ScanResult>> getAllHistory() async {
    return await LocalDatabase.getAllScanResults();
  }

  // Get scan history with pagination
  Future<List<ScanResult>> getHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    final offset = (page - 1) * pageSize;
    return await LocalDatabase.getScanResults(
      limit: pageSize,
      offset: offset,
    );
  }

  // Search history by plate number
  Future<List<ScanResult>> searchHistory(String query) async {
    if (query.isEmpty) {
      return await getAllHistory();
    }
    return await LocalDatabase.searchByPlateNumber(query);
  }

  // Get scan result by ID
  Future<ScanResult?> getById(String id) async {
    return await LocalDatabase.getScanResultById(id);
  }

  // Delete scan result
  Future<void> delete(String id) async {
    await LocalDatabase.deleteScanResult(id);
  }

  // Clear all history
  Future<void> clearAll() async {
    await LocalDatabase.deleteAllScanResults();
  }

  // Get total count
  Future<int> getCount() async {
    return await LocalDatabase.getScanResultsCount();
  }

  // Get history grouped by date
  Future<Map<DateTime, List<ScanResult>>> getHistoryGroupedByDate() async {
    final allResults = await getAllHistory();
    final grouped = <DateTime, List<ScanResult>>{};

    for (final result in allResults) {
      final dateKey = DateTime(
        result.scannedAt.year,
        result.scannedAt.month,
        result.scannedAt.day,
      );

      if (grouped.containsKey(dateKey)) {
        grouped[dateKey]!.add(result);
      } else {
        grouped[dateKey] = [result];
      }
    }

    return grouped;
  }
}
