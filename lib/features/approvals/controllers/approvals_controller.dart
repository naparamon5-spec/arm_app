import 'package:flutter/material.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/quote_model.dart';

class ApprovalsController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<QuoteModel> _allQuotes = [];
  List<QuoteModel> _filteredQuotes = [];
  String _searchQuery = '';

  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  final int _pageSize = 10;

  final ScrollController scrollController = ScrollController();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<QuoteModel> get filteredQuotes => _filteredQuotes;
  String get searchQuery => _searchQuery;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;

  ApprovalsController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        loadMoreQuotes();
      }
    });
  }

  Future<void> loadApprovals() async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasMoreData = true;
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

  Future<void> loadMoreQuotes() async {
    if (_isLoadingMore || !_hasMoreData) return;
    _isLoadingMore = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    _currentPage++;
    if (_currentPage > 5) _hasMoreData = false;
    _isLoadingMore = false;
    notifyListeners();
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

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
