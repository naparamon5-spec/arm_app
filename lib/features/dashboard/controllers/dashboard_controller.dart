import 'package:flutter/material.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/quote_model.dart';

class DashboardController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<QuoteModel> _recentQuotes = [];
  int _pendingCount = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<QuoteModel> get recentQuotes => _recentQuotes;
  int get pendingCount => _pendingCount;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      _recentQuotes = MockData.recentQuotes;
      _pendingCount = 128;
    } catch (_) {
      _errorMessage = 'Failed to load dashboard data.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
