import 'dart:typed_data';

import '../../core/api/quote_approvals_api.dart';
import '../../core/utils/json_map_extensions.dart';
import '../mappers/quote_mapper.dart';
import '../models/paginated_quotes.dart';
import '../models/quote_model.dart';

class QuoteRepository {
  final QuoteApprovalsApi quoteApi;

  QuoteRepository({required this.quoteApi});

  Future<PaginatedQuotes> getPendingQuotes({
    int page = 1,
    int pageSize = 20,
    String? dateFrom,
    String? dateTo,
    String? quoteNumber,
    String? productGroupName,
    String? customerName,
  }) async {
    final response = await quoteApi.list(
      QuoteApprovalFilters(
        page: page,
        pageSize: pageSize,
        dateFrom: dateFrom,
        dateTo: dateTo,
        quoteNumber: quoteNumber,
        productGroupName: productGroupName,
        customerName: customerName,
      ),
    );

    final rows = asJsonList(response['data']);
    final quotes = rows.map(QuoteMapper.fromListRow).toList();

    return PaginatedQuotes(
      data: quotes,
      total: _asInt(response['total']),
      page: _asInt(response['page'], page),
      pageSize: _asInt(response['pageSize'], pageSize),
      totalPages: _asInt(response['totalPages'], 1),
    );
  }

  Future<List<QuoteModel>> getRecentQuotes() async {
    final rows = await quoteApi.recent();
    return rows.map(QuoteMapper.fromListRow).toList();
  }

  Future<QuoteModel> getQuoteFull(String quoteNumber) async {
    final header = await quoteApi.getQuote(quoteNumber);
    final details = await quoteApi.getDetails(quoteNumber);
    final tpc = await quoteApi.getTpc(quoteNumber);
    final cpoFiles = await quoteApi.getCpoFiles(quoteNumber);

    return QuoteMapper.fromHeader(
      header,
      details: details,
      tpc: tpc,
      cpoFiles: cpoFiles,
    );
  }

  /// Fetches an attachment's bytes (authenticated) for in-app preview.
  Future<Uint8List> downloadFile(String filename) {
    return quoteApi.downloadFile(filename);
  }

  Future<String> approveQuote(
    String quoteNumber, {
    String? type,
    String? remarks,
  }) {
    return quoteApi.approve(
      quoteNumber,
      type: type,
      remarks: remarks,
    );
  }

  int _asInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
