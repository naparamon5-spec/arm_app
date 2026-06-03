import 'package:flutter/material.dart';

import '../../../core/config/api_config.dart';
import '../../../core/di/app_dependencies.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/quote_model.dart';

class ApprovalsController extends ChangeNotifier {
  final _quoteRepo = AppDependencies.instance.quoteRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<QuoteModel> _quotes = [];
  String _searchQuery = '';

  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;

  final ScrollController scrollController = ScrollController();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loaded quotes filtered by the current keyword (case-insensitive,
  /// partial match across quote number, customer, salesman and product).
  List<QuoteModel> get filteredQuotes {
    if (_searchQuery.isEmpty) return _quotes;
    final q = _searchQuery.toLowerCase();
    return _quotes.where((quote) {
      return quote.quoteNumber.toLowerCase().contains(q) ||
          quote.customer.toLowerCase().contains(q) ||
          quote.salesmanName.toLowerCase().contains(q) ||
          quote.product.toLowerCase().contains(q) ||
          quote.buGroup.toLowerCase().contains(q);
    }).toList();
  }

  String get searchQuery => _searchQuery;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _currentPage < _totalPages;

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
    notifyListeners();

    try {
      final result = await _fetchPage(1);
      _quotes = result.data;
      _currentPage = result.page;
      _totalPages = result.totalPages;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _quotes = [];
    } catch (_) {
      _errorMessage = 'Failed to load approvals.';
      _quotes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreQuotes() async {
    if (_isLoadingMore || !hasMoreData || _isLoading) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await _fetchPage(nextPage);
      _quotes = [..._quotes, ...result.data];
      _currentPage = result.page;
      _totalPages = result.totalPages;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load more approvals.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Keyword search. Filters the already-loaded list instantly (no network
  /// call), so typing any character — including a single digit — narrows the
  /// results right away. See [filteredQuotes] for the matched fields.
  void search(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Future<dynamic> _fetchPage(int page) {
    return _quoteRepo.getPendingQuotes(
      page: page,
      pageSize: ApiConfig.defaultPageSize,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
