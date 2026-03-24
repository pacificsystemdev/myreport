import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class ReportsProvider extends ChangeNotifier {
  List<Report> _reports = [];
  bool _isLoading = false;
  int? _filterYear;
  int? _filterMonth;
  final ApiService _apiService = ApiService();

  List<Report> get reports => _reports;
  List<Report> get filteredReports {
    return _reports.where((report) {
      if (_filterYear != null && report.reportDate.year != _filterYear)
        return false;
      if (_filterMonth != null && report.reportDate.month != _filterMonth)
        return false;
      return true;
    }).toList();
  }

  bool get isLoading => _isLoading;
  int? get filterYear => _filterYear;
  int? get filterMonth => _filterMonth;

  void setFilter({int? year, int? month}) {
    _filterYear = year;
    _filterMonth = month;
    notifyListeners();
  }

  void clearFilter() {
    _filterYear = null;
    _filterMonth = null;
    notifyListeners();
  }

  Future<void> fetchReports(
    String accessToken,
    int userId, {
    int? year,
    int? month,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.getReports(
        userId,
        accessToken,
        year: year,
        month: month,
      );
      if (response['success']) {
        _reports = (response['reports'] as List)
            .map((r) => Report.fromJson(r))
            .toList();
      } else {
        debugPrint('API error: ${response['error']}');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch reports error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReport(
    Map<String, dynamic> data,
    String token,
    int userId,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.submitReport(data, token, userId);
      if (response['success']) {
        await fetchReports(token, userId); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Submit report error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateReport(
    int reportId,
    Map<String, dynamic> data,
    String token,
    int userId,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.updateReport(
        reportId,
        data,
        token,
        userId,
      );
      if (response['success']) {
        await fetchReports(token, userId); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Update report error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
