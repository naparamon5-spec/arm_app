import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../core/config/api_config.dart';

class PrintService {
  Future<File> downloadPdf({
    required String quoteNumber,
    required String type,
    required String accessToken,
  }) async {
    final url =
        '${ApiConfig.baseUrl}/api/quote-approvals/$quoteNumber/$type';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final filename =
          'QT${quoteNumber}_${type}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception(
        'Failed to load PDF (${response.statusCode})',
      );
    }
  }
}
