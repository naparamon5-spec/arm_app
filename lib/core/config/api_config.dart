/// Base URL and timeouts for the Quote Approval API.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl =
      'https://quote-approval-api.ardentnetworks.com.ph';

  static const Duration connectTimeout = Duration(seconds: 15);
  // Temporarily raised from 30s to diagnose slow API responses (see For Approval timeout).
  static const Duration receiveTimeout = Duration(seconds: 120);

  static const int defaultPageSize = 20;
}
