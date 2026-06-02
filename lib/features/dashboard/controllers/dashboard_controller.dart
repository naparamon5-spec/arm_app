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

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final recent = await _quoteRepo.getRecentQuotes();
      _recentQuotes = recent;

      final page = await _quoteRepo.getPendingQuotes(page: 1, pageSize: 1);
      _pendingCount = page.total;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load dashboard data.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
