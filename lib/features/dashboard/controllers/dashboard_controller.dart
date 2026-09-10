import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/quote_model.dart';

class DashboardController extends ChangeNotifier {
  final _quoteRepo = AppDependencies.instance.quoteRepository;
  final _session = AppDependencies.instance.sessionService;

  bool _isLoading = false;
  String? _errorMessage;
  List<QuoteModel> _recentQuotes = [];
  int _pendingCount = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<QuoteModel> get recentQuotes => _recentQuotes;
  int get pendingCount => _pendingCount;

  String get welcomeName {
    final user = _session.currentUser;
    if (user == null) return '';
    final parts = user.fullName.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : user.id;
  }

  /// Loads the dashboard data.
  ///
  /// Pass [silent] to refresh in the background without toggling the
  /// full-screen loading spinner — used when the dashboard tab regains focus
  /// so already-visible content isn't replaced by a spinner (and a transient
  /// failure doesn't blow the list away with an error screen).
  Future<void> loadDashboard({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final recent = await _quoteRepo.getRecentQuotes();
      final page = await _quoteRepo.getPendingQuotes(page: 1, pageSize: 1);
      _recentQuotes = recent;
      _pendingCount = page.total;
      _errorMessage = null;
      debugPrint(
          '[Dashboard] loaded ${_recentQuotes.length} recent quotes, total=${page.total}');
    } on ApiException catch (e) {
      debugPrint('[Dashboard] ApiException: ${e.message} (${e.statusCode})');
      // Keep the existing content visible on a silent refresh failure.
      if (!silent) _errorMessage = e.message;
    } catch (e, st) {
      debugPrint('[Dashboard] unexpected error: $e\n$st');
      if (!silent) _errorMessage = 'Failed to load dashboard data.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
