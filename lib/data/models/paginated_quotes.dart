import 'quote_model.dart';

class PaginatedQuotes {
  final List<QuoteModel> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginatedQuotes({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}
