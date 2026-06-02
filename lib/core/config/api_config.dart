/// Base URL and timeouts for the Quote Approval API.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl =
      'https://quote-approval-api.ardentnetworks.com.ph';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const int defaultPageSize = 20;
}
