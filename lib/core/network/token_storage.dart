import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists auth tokens and logged-in user id securely on device.
///
/// Android's EncryptedSharedPreferences backend is not safe under concurrent
/// access: overlapping reads/writes (e.g. a token refresh writing while several
/// requests read during a multitask resume) can corrupt or drop values, which
/// then surface as a lost session on the next cold start. Every operation is
/// therefore funnelled through [_lock] so only one touches the store at a time.
class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _biometricEnabledKey = 'biometric_enabled';
  static const _biometricUserIdKey = 'biometric_cred_user_id';
  static const _biometricPasswordKey = 'biometric_cred_password';

  final FlutterSecureStorage _storage;

  /// Serialises access to the underlying secure storage.
  Future<void> _lock = Future.value();

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  /// Runs [action] after any in-flight storage operation completes, so reads
  /// and writes are never issued concurrently against the secure store.
  Future<T> _synchronized<T>(Future<T> Function() action) {
    final completer = _lock.then((_) => action());
    // Keep the chain alive even if this action fails, so a single error does
    // not wedge every later operation.
    _lock = completer.then((_) {}, onError: (_) {});
    return completer;
  }

  Future<String?> get accessToken => _read(_accessTokenKey);

  Future<String?> get refreshToken => _read(_refreshTokenKey);

  Future<String?> get userId => _read(_userIdKey);

  /// Whether the user has opted in to biometric login. This preference is kept
  /// separate from the session tokens and intentionally survives [clear] /
  /// sign-out, so re-logging in keeps the toggle as the user left it.
  Future<bool> isBiometricEnabled() => _synchronized(() async {
        try {
          return (await _storage.read(key: _biometricEnabledKey)) == 'true';
        } catch (_) {
          return false;
        }
      });

  Future<void> setBiometricEnabled(bool value) => _synchronized(() async {
        await _storage.write(
          key: _biometricEnabledKey,
          value: value ? 'true' : 'false',
        );
      });

  /// Credentials captured for biometric login. Stored in the OS secure store
  /// and — like [_biometricEnabledKey] — deliberately NOT removed by [clear] /
  /// sign-out, so biometric login keeps working after the user signs out (which
  /// also revokes the server tokens). Cleared only when the toggle is turned
  /// off or a stored credential is rejected by the backend.
  Future<void> setBiometricCredentials({
    required String userId,
    required String password,
  }) =>
      _synchronized(() async {
        await _storage.write(key: _biometricUserIdKey, value: userId);
        await _storage.write(key: _biometricPasswordKey, value: password);
      });

  Future<({String userId, String password})?> biometricCredentials() =>
      _synchronized(() async {
        try {
          final u = await _storage.read(key: _biometricUserIdKey);
          final p = await _storage.read(key: _biometricPasswordKey);
          if (u == null || u.isEmpty || p == null || p.isEmpty) return null;
          return (userId: u, password: p);
        } catch (_) {
          return null;
        }
      });

  Future<bool> hasBiometricCredentials() => _synchronized(() async {
        try {
          final u = await _storage.read(key: _biometricUserIdKey);
          return u != null && u.isNotEmpty;
        } catch (_) {
          return false;
        }
      });

  Future<void> clearBiometricCredentials() => _synchronized(() async {
        await _storage.delete(key: _biometricUserIdKey);
        await _storage.delete(key: _biometricPasswordKey);
      });

  Future<String?> _read(String key) => _synchronized(() async {
        try {
          return await _storage.read(key: key);
        } catch (_) {
          // A corrupt/undecodable entry should read as absent rather than throw
          // and crash startup.
          return null;
        }
      });

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) {
    return _synchronized(() async {
      // Sequential writes — never run them in parallel on Android.
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      await _storage.write(key: _userIdKey, value: userId);
    });
  }

  Future<void> clear() {
    return _synchronized(() async {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userIdKey);
    });
  }
}
