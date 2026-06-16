/// Thrown when the API returns an error or the request fails.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  static String messageFromResponse(dynamic data, String fallback) {
    if (data == null) return fallback;
    if (data is Map) {
      final error = data['error'] ?? data['message'];
      if (error is String && error.trim().isNotEmpty) return error.trim();
      return fallback;
    }
    if (data is String) {
      final text = data.trim();
      // Reject HTML error pages (e.g. a proxy's "504 Gateway Timeout" page) and
      // anything too long to be a user-facing message — show the fallback.
      if (text.isEmpty || _looksLikeHtml(text) || text.length > 200) {
        return fallback;
      }
      return text;
    }
    return fallback;
  }

  static bool _looksLikeHtml(String text) {
    final lower = text.toLowerCase();
    return lower.startsWith('<!doctype') ||
        lower.startsWith('<html') ||
        lower.startsWith('<') ||
        lower.contains('<head') ||
        lower.contains('<body') ||
        lower.contains('</');
  }
}
