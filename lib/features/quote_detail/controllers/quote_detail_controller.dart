import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/quote_model.dart';

class QuoteDetailController extends ChangeNotifier {
  final _quoteRepo = AppDependencies.instance.quoteRepository;

  bool _isLoading = false;
  String? _errorMessage;
  QuoteModel? _quote;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  QuoteModel? get quote => _quote;

  void loadQuote(QuoteModel summary) {
    _quote = summary;
    notifyListeners();
    _loadFullQuote(summary.quoteNumber);
  }

  Future<void> _loadFullQuote(String quoteNumber) async {
    if (quoteNumber.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _quote = await _quoteRepo.getQuoteFull(quoteNumber);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load quote details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveQuote({
    String? type,
    String? remarks,
    required VoidCallback onSuccess,
  }) async {
    final current = _quote;
    if (current == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _quoteRepo.approveQuote(
        current.quoteNumber,
        type: type,
        remarks: remarks,
      );
      onSuccess();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to approve quote. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
