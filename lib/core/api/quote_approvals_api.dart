import 'dart:convert';
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
      final data = Map<String, dynamic>.from(response.data ?? {});
      final rowCount = data['data'] is List ? (data['data'] as List).length : 0;
      // ignore: avoid_print
      print('[QuoteApi] list query=${filters.toQuery()} '
          '-> rows=$rowCount total=${data['total']} '
          'page=${data['page']} totalPages=${data['totalPages']}');
      return data;
    } on DioException catch (e) {
      // ignore: avoid_print
      print('[QuoteApi] list error: type=${e.type} status=${e.response?.statusCode} msg=${e.message} err=${e.error}');
      _client.throwFromDio(e, 'Failed to retrieve approvals');
    }
  }

  Future<List<Map<String, dynamic>>> recent() async {
    try {
      // ignore: avoid_print
      print('[QuoteApi] recent GET ${ApiPaths.quoteApprovalsRecent}');
      final response = await _client.get<dynamic>(
        ApiPaths.quoteApprovalsRecent,
      );
      final body = response.data;
      // ignore: avoid_print
      print('[QuoteApi] recent status=${response.statusCode} '
          'bodyType=${body.runtimeType}');
      // ignore: avoid_print
      print('[QuoteApi] recent raw body: $body');

      // The endpoint may return: a Map wrapping rows under `result`/`data`, or a
      // bare list. Each row may be a plain object or a JSON-encoded string.
      dynamic rowsRaw;
      if (body is Map) {
        // ignore: avoid_print
        print('[QuoteApi] recent map keys=${body.keys.toList()}');
        rowsRaw = body['result'] ?? body['data'] ?? body['recent'];
      } else if (body is List) {
        rowsRaw = body;
      }
      // ignore: avoid_print
      print('[QuoteApi] recent rowsRaw type=${rowsRaw.runtimeType} '
          'len=${rowsRaw is List ? rowsRaw.length : 'n/a'} '
          'firstType=${rowsRaw is List && rowsRaw.isNotEmpty ? rowsRaw.first.runtimeType : 'n/a'}');

      final rows = _asRowList(rowsRaw);
      // ignore: avoid_print
      print('[QuoteApi] recent -> parsed rows=${rows.length}');
      if (rows.isNotEmpty) {
        // ignore: avoid_print
        print('[QuoteApi] recent first parsed keys=${rows.first.keys.toList()}');
      }
      return rows;
    } on DioException catch (e) {
      // ignore: avoid_print
      print('[QuoteApi] recent error: type=${e.type} status=${e.response?.statusCode} msg=${e.message} err=${e.error} data=${e.response?.data}');
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
      print('[QuoteApi] getQuote $quoteNumber -> ok');
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
      return data.map(_asRow).where((m) => m.isNotEmpty).toList();
    }
    return [];
  }

  /// A row may be a plain map or a JSON-encoded string (the live list/recent
  /// endpoints return the latter inside their array).
  Map<String, dynamic> _asRow(dynamic e) {
    if (e is Map) return Map<String, dynamic>.from(e);
    if (e is String) {
      final s = e.trim();
      if (s.startsWith('{')) {
        try {
          final decoded = jsonDecode(s);
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        } catch (_) {
          // fall through to empty map
        }
      }
    }
    return <String, dynamic>{};
  }
}
