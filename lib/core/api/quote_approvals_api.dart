import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../network/api_client.dart';
import 'api_paths.dart';

/// Query filters for GET /api/quote-approvals (see API.md).
class QuoteApprovalFilters {
  final int page;
  final int pageSize;
  final String? dateFrom;
  final String? dateTo;
  final String? quoteNumber;
  final String? productGroupName;
  final String? customerName;

  const QuoteApprovalFilters({
    this.page = 1,
    this.pageSize = ApiConfig.defaultPageSize,
    this.dateFrom,
    this.dateTo,
    this.quoteNumber,
    this.productGroupName,
    this.customerName,
  });

  Map<String, dynamic> toQuery() {
    final query = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (dateFrom != null && dateFrom!.isNotEmpty) {
      query['date_from'] = dateFrom;
    }
    if (dateTo != null && dateTo!.isNotEmpty) {
      query['date_to'] = dateTo;
    }
    if (quoteNumber != null && quoteNumber!.isNotEmpty) {
      query['quote_number'] = quoteNumber;
    }
    if (productGroupName != null && productGroupName!.isNotEmpty) {
      query['product_group_name'] = productGroupName;
    }
    if (customerName != null && customerName!.isNotEmpty) {
      query['customer_name'] = customerName;
    }
    return query;
  }
}

class QuoteApprovalsApi {
  final ApiClient _client;

  QuoteApprovalsApi(this._client);

  Future<Map<String, dynamic>> list(QuoteApprovalFilters filters) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        ApiPaths.quoteApprovals,
        queryParameters: filters.toQuery(),
      );
      // ignore: avoid_print
      print('[QuoteApi] list query: ${filters.toQuery()}');
      // ignore: avoid_print
      print('[QuoteApi] list raw: ${response.data}');
      return Map<String, dynamic>.from(response.data ?? {});
    } on DioException catch (e) {
      // ignore: avoid_print
      print('[QuoteApi] list error: type=${e.type} status=${e.response?.statusCode} msg=${e.message} err=${e.error}');
      _client.throwFromDio(e, 'Failed to retrieve approvals');
    }
  }

  Future<List<Map<String, dynamic>>> recent() async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        ApiPaths.quoteApprovalsRecent,
      );
      // ignore: avoid_print
      print('[QuoteApi] recent raw: ${response.data}');
      final data = response.data?['data'];
      return _asRowList(data);
    } on DioException catch (e) {
      // ignore: avoid_print
      print('[QuoteApi] recent error: type=${e.type} status=${e.response?.statusCode} msg=${e.message} err=${e.error}');
      _client.throwFromDio(e, 'Failed to retrieve recent approvals');
    }
  }

  String _encoded(String quoteNumber) => Uri.encodeComponent(quoteNumber);

  Future<Map<String, dynamic>> getQuote(String quoteNumber) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        ApiPaths.quoteApproval(_encoded(quoteNumber)),
      );
      // ignore: avoid_print
      print('[QuoteApi] getQuote raw: ${response.data}');
      return Map<String, dynamic>.from(response.data ?? {});
    } on DioException catch (e) {
      // ignore: avoid_print
      print('[QuoteApi] getQuote error: type=${e.type} status=${e.response?.statusCode} data=${e.response?.data}');
      _client.throwFromDio(e, 'Failed to retrieve quote');
    }
  }

  Future<List<Map<String, dynamic>>> getDetails(String quoteNumber) async {
    try {
      final response = await _client.get<dynamic>(
        ApiPaths.quoteDetails(_encoded(quoteNumber)),
      );
      return _asRowList(response.data);
    } on DioException catch (e) {
      _client.throwFromDio(e, 'Failed to retrieve quote details');
    }
  }

  Future<List<Map<String, dynamic>>> getTpc(String quoteNumber) async {
    try {
      final response = await _client.get<dynamic>(
        ApiPaths.quoteTpc(_encoded(quoteNumber)),
      );
      return _asRowList(response.data);
    } on DioException catch (e) {
      _client.throwFromDio(e, 'Failed to retrieve quote TPC');
    }
  }

  Future<List<Map<String, dynamic>>> getCpoFiles(String quoteNumber) async {
    try {
      final response = await _client.get<dynamic>(
        ApiPaths.quoteCpoFiles(_encoded(quoteNumber)),
      );
      final data = response.data;
      // The endpoint returns either a bare array or a { "files": [...] } wrapper.
      final rows = data is Map ? (data['files'] ?? data['data']) : data;
      return _asRowList(rows);
    } on DioException catch (e) {
      _client.throwFromDio(e, 'Failed to retrieve CPO files');
    }
  }

  /// Downloads an uploaded file's bytes via the authenticated endpoint
  /// GET /api/quote-approvals/files/:filename — used to preview files in-app.
  Future<Uint8List> downloadFile(String filename) async {
    try {
      final response = await _client.getBytes(ApiPaths.quoteFile(filename));
      return Uint8List.fromList(response.data ?? const []);
    } on DioException catch (e) {
      // ignore: avoid_print
      print('[QuoteApi] downloadFile error: filename=$filename '
          'status=${e.response?.statusCode} msg=${e.message}');
      _client.throwFromDio(e, 'Failed to download file');
    }
  }

  Future<String> approve(
    String quoteNumber, {
    String? type,
    String? remarks,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (type != null && type.isNotEmpty) body['type'] = type;
      if (remarks != null && remarks.isNotEmpty) body['remarks'] = remarks;

      final response = await _client.put<Map<String, dynamic>>(
        ApiPaths.quoteApprove(_encoded(quoteNumber)),
        data: body.isEmpty ? null : body,
      );
      final message = response.data?['message']?.toString();
      return message ?? 'Quote approved';
    } on DioException catch (e) {
      _client.throwFromDio(e, 'Failed to approve quote');
    }
  }

  List<Map<String, dynamic>> _asRowList(dynamic data) {
    if (data is List) {
      return data
          .map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
          .where((m) => m.isNotEmpty)
          .toList();
    }
    return [];
  }
}
