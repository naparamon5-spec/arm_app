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
