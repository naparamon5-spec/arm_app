import 'package:flutter/material.dart';
import '../../../data/models/quote_model.dart';

class QuoteDetailController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  QuoteModel? _quote;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  QuoteModel? get quote => _quote;

  void loadQuote(QuoteModel quote) {
    _quote = quote;
    notifyListeners();
  }

  Future<void> approveQuote({required VoidCallback onSuccess}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      onSuccess();
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
