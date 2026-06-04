import 'dart:async';

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
  Timer? _debounce;

  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;

  final ScrollController scrollController = ScrollController();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isLoadingMore => _isLoadingMore;

  /// Load-more only applies during normal (non-search) browsing.
  bool get hasMoreData => _searchQuery.isEmpty && _currentPage < _totalPages;

  List<QuoteModel> get filteredQuotes => _quotes;

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
      if (_searchQuery.isEmpty) {
        final result = await _quoteRepo.getPendingQuotes(
          page: 1,
          pageSize: ApiConfig.defaultPageSize,
        );
        _quotes = result.data;
        _currentPage = result.page;
        _totalPages = result.totalPages;
      } else if (int.tryParse(_searchQuery) != null) {
        // Numeric → exact quote_number match
        final result = await _quoteRepo.getPendingQuotes(
          page: 1,
          pageSize: 100,
          quoteNumber: _searchQuery,
        );
        _quotes = result.data;
        _totalPages = 1;
      } else {
        // Text → fetch from 3 sources in parallel, merge, filter client-side
        _quotes = await _textSearch(_searchQuery.toLowerCase());
        _totalPages = 1;
      }
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

  /// Fires 3 API calls in parallel (customer_name, product_group_name,
  /// and an unfiltered batch), merges by quote number, then filters
  /// client-side to include salesman name matches.
  Future<List<QuoteModel>> _textSearch(String query) async {
    final batches = await Future.wait([
      _safeFetch(customerName: query, pageSize: 200),
      _safeFetch(productGroupName: query, pageSize: 200),
      _safeFetch(pageSize: 500),
    ]);

    final merged = <String, QuoteModel>{};
    for (final batch in batches) {
      for (final q in batch) {
        merged[q.quoteNumber] = q;
      }
    }

    return merged.values.where((q) {
      return q.quoteNumber.toLowerCase().contains(query) ||
          q.customer.toLowerCase().contains(query) ||
          q.product.toLowerCase().contains(query) ||
          q.salesmanName.toLowerCase().contains(query) ||
          q.buGroup.toLowerCase().contains(query);
    }).toList();
  }

  Future<List<QuoteModel>> _safeFetch({
    String? customerName,
    String? productGroupName,
    int pageSize = ApiConfig.defaultPageSize,
  }) async {
    try {
      final result = await _quoteRepo.getPendingQuotes(
        page: 1,
        pageSize: pageSize,
        customerName: customerName,
        productGroupName: productGroupName,
      );
      return result.data;
    } catch (_) {
      return [];
    }
  }

  Future<void> loadMoreQuotes() async {
    if (_isLoadingMore || !hasMoreData || _isLoading) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await _quoteRepo.getPendingQuotes(
        page: nextPage,
        pageSize: ApiConfig.defaultPageSize,
      );
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

  void search(String query) {
    _searchQuery = query.trim();
    notifyListeners();

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), loadApprovals);
  }

  void clearSearch() {
    _debounce?.cancel();
    _searchQuery = '';
    notifyListeners();
    loadApprovals();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    scrollController.dispose();
    super.dispose();
  }
}
