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
  List<QuoteModel> get filteredQuotes => _quotes;
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

  Future<void> search(String query) async {
    _searchQuery = query.trim();
    await loadApprovals();
  }

  void clearSearch() {
    _searchQuery = '';
    loadApprovals();
  }

  Future<dynamic> _fetchPage(int page) {
    final q = _searchQuery;
    return _quoteRepo.getPendingQuotes(
      page: page,
      pageSize: ApiConfig.defaultPageSize,
      quoteNumber: _looksLikeQuoteNumber(q) ? q : null,
      customerName: _looksLikeQuoteNumber(q) ? null : (q.isEmpty ? null : q),
      productGroupName: null,
    );
  }

  bool _looksLikeQuoteNumber(String q) {
    if (q.isEmpty) return false;
    return RegExp(r'^[#Q\d\-]', caseSensitive: false).hasMatch(q);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
