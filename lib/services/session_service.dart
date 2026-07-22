import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

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
    final accessToken = await tokenStorage.accessToken;
    final refreshToken = await tokenStorage.refreshToken;

    if (userId == null || userId.isEmpty) {
      _currentUser = null;
      return;
    }

    final hasRefresh = refreshToken != null && refreshToken.isNotEmpty;
    final hasAccess = accessToken != null && accessToken.isNotEmpty;

    // Startup must NEVER block on the network — doing so leaves the app frozen
    // on the launch screen for up to the request timeout when the API is slow
    // or unreachable. So we restore the session purely from local storage here.
    //
    // An expired access token is NOT an immediate logout, and we do NOT wait on
    // a refresh to renew it: the reactive 401 interceptor (see ApiClient) renews
    // the token on the first real API call, and expires the session if the
    // refresh token is also dead. This keeps launch instant and offline-safe.
    if (hasAccess) {
      // Decode the stored token for immediate display. Even if it's expired, the
      // reactive refresh path replaces it on the first authenticated request.
      _currentUser = _userFromToken(userId, accessToken);

      // If the access token has already expired, warm up a fresh one in the
      // background so the first API call likely arrives with a valid token.
      // Deliberately not awaited: startup must not wait on this.
      if (_isTokenExpired(accessToken) && hasRefresh) {
        unawaited(Future(() => refreshTokens?.call()));
      }
      return;
    }

    // No usable access token to build a session from offline (tokens are
    // normally stored together, so this is rare). The session can't be restored
    // without a network round trip, which we won't do on the launch path — send
    // the user to login, where a fresh sign-in re-establishes the session.
    await clearSession();
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
    // Debug-only: inspect which fields the API puts in the JWT. Never logged in
    // release builds — token claims are sensitive.
    if (kDebugMode) debugPrint('[Session] token claims=$claims');
    final name = claims?['name']?.toString() ??
        claims?['full_name']?.toString() ??
        claims?['user_name']?.toString() ??
        userId;
    final role = claims?['role']?.toString() ??
        claims?['privilege']?.toString() ??
        'Quote Approver';
    final email = claims?['email']?.toString() ?? '';
    final employeeId = claims?['employee_id']?.toString() ??
        claims?['employeeId']?.toString() ??
        claims?['EMPLOYEE_ID']?.toString() ??
        claims?['emp_id']?.toString() ??
        claims?['EMP_ID']?.toString() ??
        userId;
    final classification = claims?['classification']?.toString() ??
        claims?['CLASSIFICATION']?.toString() ??
        claims?['class']?.toString() ??
        claims?['CLASS']?.toString() ??
        '';

    return UserModel(
      id: userId,
      fullName: name,
      role: role,
      email: email.isNotEmpty ? email : userId,
      employeeId: employeeId,
      classification: classification,
    );
  }

  /// Whether a JWT access token is expired (or expires within [leeway]).
  ///
  /// The [leeway] refreshes a token that's about to lapse so we don't hand a
  /// request a token that dies in-flight. A token with no readable `exp` claim
  /// is treated as NOT expired — we fall back to the reactive 401 refresh path
  /// rather than forcing a logout on a token we can't reason about.
  bool _isTokenExpired(String token,
      {Duration leeway = const Duration(seconds: 30)}) {
    final claims = _decodeJwtPayload(token);
    final exp = claims?['exp'];
    final expSeconds = exp is int ? exp : int.tryParse(exp?.toString() ?? '');
    if (expSeconds == null) return false;
    final expiry =
        DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true);
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
