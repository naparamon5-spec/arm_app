import 'package:flutter/material.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/quote_model.dart';

class ApprovalsController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<QuoteModel> _allQuotes = [];
  List<QuoteModel> _filteredQuotes = [];
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<QuoteModel> get filteredQuotes => _filteredQuotes;
  String get searchQuery => _searchQuery;

  Future<void> loadApprovals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      _allQuotes = MockData.pendingQuotes;
      _filteredQuotes = List.from(_allQuotes);
    } catch (_) {
      _errorMessage = 'Failed to load approvals.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query.trim().toLowerCase();
    if (_searchQuery.isEmpty) {
      _filteredQuotes = List.from(_allQuotes);
    } else {
      _filteredQuotes = _allQuotes.where((q) {
        return q.quoteNumber.toLowerCase().contains(_searchQuery) ||
            q.customer.toLowerCase().contains(_searchQuery) ||
            q.salesmanName.toLowerCase().contains(_searchQuery) ||
            q.product.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredQuotes = List.from(_allQuotes);
    notifyListeners();
  }
}
