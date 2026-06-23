import 'dart:convert';

import '../core/network/token_storage.dart';
import '../data/models/user_model.dart';

/// Holds the active session (tokens + display user) for the app.
class SessionService {
  final TokenStorage tokenStorage;

  UserModel? _currentUser;
  bool _rememberDevice = true;

  /// Refreshes the access token using the stored refresh token.
  /// Wired by the DI layer to [ApiClient.refreshSession].
  Future<bool> Function()? refreshTokens;

  SessionService({required this.tokenStorage});

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get rememberDevice => _rememberDevice;

  void setRememberDevice(bool value) => _rememberDevice = value;

  Future<void> restoreSession() async {
    final userId = await tokenStorage.userId;
    var accessToken = await tokenStorage.accessToken;
    final refreshToken = await tokenStorage.refreshToken;

    if (userId == null || userId.isEmpty) {
      _currentUser = null;
      return;
    }

    // An expired access token is NOT an immediate logout: the refresh token may
    // still be valid. When the access token is missing OR already expired, try
    // to recover it via the refresh token at startup. If that fails (no refresh
    // token, or it's expired/revoked), the session is genuinely over. A token
    // that's still valid is used as-is, so startup stays offline-friendly and
    // instant.
    final hasRefresh = refreshToken != null && refreshToken.isNotEmpty;
    final accessUsable = accessToken != null &&
        accessToken.isNotEmpty &&
        !_isTokenExpired(accessToken);
    if (!accessUsable) {
      // No usable access token. Try to recover via the refresh token; if that
      // fails (no refresh token, or it's expired/revoked), the session is over.
      final refreshed = hasRefresh && (await refreshTokens?.call() ?? false);
      accessToken = refreshed ? await tokenStorage.accessToken : null;
      if (accessToken == null || accessToken.isEmpty) {
        await clearSession();
        return;
      }
    }

    _currentUser = _userFromToken(userId, accessToken);
  }

  Future<void> setSession({
    required String userId,
    required String accessToken,
    required String refreshToken,
  }) async {
    if (_rememberDevice) {
      await tokenStorage.saveSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
      );
    }
    _currentUser = _userFromToken(userId, accessToken);
  }

  Future<void> clearSession() async {
    await tokenStorage.clear();
    _currentUser = null;
  }

  UserModel _userFromToken(String userId, String accessToken) {
    final claims = _decodeJwtPayload(accessToken);
    final name = claims?['name']?.toString() ??
        claims?['full_name']?.toString() ??
        claims?['user_name']?.toString() ??
        userId;
    final role = claims?['role']?.toString() ??
        claims?['privilege']?.toString() ??
        'Quote Approver';
    final email = claims?['email']?.toString() ?? '';

    return UserModel(
      id: userId,
      fullName: name,
      role: role,
      email: email.isNotEmpty ? email : userId,
    );
  }

  /// Whether a JWT access token is expired (or expires within [leeway]).
  ///
  /// The [leeway] refreshes a token that's about to lapse so we don't hand a
  /// request a token that dies in-flight. A token with no readable `exp` claim
  /// is treated as NOT expired — we fall back to the reactive 401 refresh path
  /// rather than forcing a logout on a token we can't reason about.
  bool _isTokenExpired(String token, {Duration leeway = const Duration(seconds: 30)}) {
    final claims = _decodeJwtPayload(token);
    final exp = claims?['exp'];
    final expSeconds = exp is int ? exp : int.tryParse(exp?.toString() ?? '');
    if (expSeconds == null) return false;
    final expiry = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true);
    return DateTime.now().toUtc().add(leeway).isAfter(expiry);
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      var payload = parts[1];
      final mod = payload.length % 4;
      if (mod > 0) payload += '=' * (4 - mod);
      final decoded = utf8.decode(base64Url.decode(payload));
      final json = jsonDecode(decoded);
      if (json is Map<String, dynamic>) return json;
      if (json is Map) return Map<String, dynamic>.from(json);
    } catch (_) {}
    return null;
  }
}
