/// Central registry of API routes — matches docs/API.md.
class ApiPaths {
  ApiPaths._();

  // Health
  static const String health = '/health';

  // App version (Android update check)
  static const String appVersion = '/api/app/version';

  // Auth — /api/auth
  static const String authLogin = '/api/auth/login';
  static const String authRefresh = '/api/auth/refresh';
  static const String authLogout = '/api/auth/logout';
  static const String authChangePassword = '/api/auth/change-password';

  // Quote approvals — /api/quote-approvals
  static const String quoteApprovals = '/api/quote-approvals';
  static const String quoteApprovalsRecent = '/api/quote-approvals/recent';

  static String quoteApproval(String quoteNumber) =>
      '/api/quote-approvals/$quoteNumber';

  static String quoteDetails(String quoteNumber) =>
      '/api/quote-approvals/$quoteNumber/details';

  static String quoteTpc(String quoteNumber) =>
      '/api/quote-approvals/$quoteNumber/tpc';

  static String quoteCpoFiles(String quoteNumber) =>
      '/api/quote-approvals/$quoteNumber/cpo-files';

  /// Streams/downloads a single uploaded file by its stored filename.
  /// GET /api/quote-approvals/files/:filename
  static String quoteFile(String filename) =>
      '/api/quote-approvals/files/${Uri.encodeComponent(filename)}';

  static String quoteApprove(String quoteNumber) =>
      '/api/quote-approvals/$quoteNumber/approve';
}
