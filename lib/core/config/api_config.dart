/// Base URL and timeouts for the Quote Approval API.
/// The base URL is injected at build time via --dart-define-from-file=.env
/// e.g. flutter run --dart-define-from-file=.env
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://quote-approval-api.ardentnetworks.com.ph',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  // Temporarily raised from 30s to diagnose slow API responses (see For Approval timeout).
  static const Duration receiveTimeout = Duration(seconds: 120);

  static const int defaultPageSize = 20;
}
