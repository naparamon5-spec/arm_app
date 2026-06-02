/// Thrown when the API returns an error or the request fails.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  static String messageFromResponse(dynamic data, String fallback) {
    if (data == null) return fallback;
    if (data is String && data.isNotEmpty) return data;
    if (data is Map) {
      final error = data['error'] ?? data['message'];
      if (error is String && error.isNotEmpty) return error;
    }
    return fallback;
  }
}
