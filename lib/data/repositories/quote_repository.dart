import '../models/quote_model.dart';
import '../mock/mock_data.dart';

class QuoteRepository {
  Future<List<QuoteModel>> getPendingQuotes() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockData.pendingQuotes;
  }

  Future<QuoteModel?> getQuoteByNumber(String quoteNumber) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return MockData.pendingQuotes.firstWhere(
        (q) => q.quoteNumber == quoteNumber,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> approveQuote(String quoteNumber) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> rejectQuote(String quoteNumber, {String? reason}) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
