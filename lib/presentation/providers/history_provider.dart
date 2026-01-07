import 'package:flutter/foundation.dart';

import '../../data/models/scan_result.dart';
import '../../data/repositories/history_repository.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryRepository _repository;

  List<ScanResult> _history = [];
  Map<DateTime, List<ScanResult>> _groupedHistory = {};
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  HistoryProvider({HistoryRepository? repository})
      : _repository = repository ?? HistoryRepository();

  // Getters
  List<ScanResult> get history => _history;
  Map<DateTime, List<ScanResult>> get groupedHistory => _groupedHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int get totalCount => _history.length;

  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _history = await _repository.getAllHistory();
      _groupedHistory = await _repository.getHistoryGroupedByDate();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();

    try {
      _history = await _repository.searchHistory(query);
      _groupHistory();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _groupHistory() {
    _groupedHistory.clear();

    for (final result in _history) {
      final dateKey = DateTime(
        result.scannedAt.year,
        result.scannedAt.month,
        result.scannedAt.day,
      );

      if (_groupedHistory.containsKey(dateKey)) {
        _groupedHistory[dateKey]!.add(result);
      } else {
        _groupedHistory[dateKey] = [result];
      }
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _repository.delete(id);
      _history.removeWhere((item) => item.id == id);
      _groupHistory();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearAll() async {
    try {
      await _repository.clearAll();
      _history.clear();
      _groupedHistory.clear();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    loadHistory();
  }

  // Get date label for display
  String getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Hom nay';
    } else if (date == yesterday) {
      return 'Hom qua';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
