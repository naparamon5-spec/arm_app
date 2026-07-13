import 'package:dio/dio.dart';

import '../api/api_paths.dart';
import '../config/api_config.dart';
import 'api_exception.dart';
import 'token_storage.dart';

/// Shared HTTP client with auth header injection and token refresh.
class ApiClient {
  final TokenStorage tokenStorage;
  late final Dio dio;

  /// A single in-flight refresh shared by all concurrent 401s, so that
  /// overlapping requests (e.g. when returning from the background) wait for
  /// one refresh instead of each kicking off its own and racing.
  Future<bool>? _refreshFuture;

  /// Invoked when the refresh token is rejected by the server (expired/revoked).
  /// The session is truly over — wired by the DI layer to clear it and send the
  /// user back to login. NOT called for transient network errors.
  Future<void> Function()? onSessionExpired;

  ApiClient({required this.tokenStorage}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final skipAuth = options.extra['skipAuth'] == true;
          if (!skipAuth) {
            final token = await tokenStorage.accessToken;
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final response = error.response;
          if (response?.statusCode == 401 &&
              error.requestOptions.extra['skipAuth'] != true &&
              error.requestOptions.extra['retried'] != true) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              try {
                final opts = error.requestOptions;
                opts.extra['retried'] = true;
                final token = await tokenStorage.accessToken;
                opts.headers['Authorization'] = 'Bearer $token';
                final retryResponse = await dio.fetch(opts);
                return handler.resolve(retryResponse);
              } catch (_) {
                // Fall through to original error handling.
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Proactively refresh the access token using the stored refresh token.
  /// Safe to call on app start; coalesces with any in-flight refresh.
  Future<bool> refreshSession() => _tryRefreshToken();

  /// Refreshes the access token, coalescing concurrent callers onto a single
  /// request. Callers that arrive while a refresh is already running await the
  /// same result and retry once it completes, instead of failing their request.
  Future<bool> _tryRefreshToken() {
    return _refreshFuture ??= _performRefresh().whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<bool> _performRefresh() async {
    final refresh = await tokenStorage.refreshToken;
    if (refresh == null || refresh.isEmpty) {
      // Nothing to refresh with — the session cannot be recovered.
      await _expireSession();
      return false;
    }

    try {
      final response = await dio.post(
        ApiPaths.authRefresh,
        data: {'refresh_token': refresh},
        options: Options(extra: {'skipAuth': true}),
      );
      final data = response.data;
      if (data is! Map) return false;
      final accessToken = data['access_token']?.toString();
      if (accessToken == null || accessToken.isEmpty) return false;

      final userId = await tokenStorage.userId ?? '';
      await tokenStorage.saveSession(
        accessToken: accessToken,
        refreshToken: refresh,
        userId: userId,
      );
      return true;
    } on DioException catch (e) {
      // A 401/403 means the refresh token is expired or revoked — the session
      // is genuinely over, so log out. Network/timeout/5xx errors are transient
      // and must NOT log the user out; let them retry.
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        await _expireSession();
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  bool _expiring = false;

  /// Fires the session-expired hook once, after clearing the in-flight refresh.
  Future<void> _expireSession() async {
    if (_expiring) return;
    _expiring = true;
    try {
      await onSessionExpired?.call();
    } finally {
      _expiring = false;
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool skipAuth = false,
  }) {
    return dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: Options(extra: {'skipAuth': skipAuth}),
    );
  }

  /// Downloads a binary resource (e.g. an uploaded file) as raw bytes, with the
  /// Authorization header attached so protected endpoints can be opened in-app.
  Future<Response<List<int>>> getBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.get<List<int>>(
      path,
      queryParameters: queryParameters,
      options: Options(
        responseType: ResponseType.bytes,
        extra: {'skipAuth': false},
      ),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    bool skipAuth = false,
  }) {
    return dio.post<T>(
      path,
      data: data,
      options: Options(extra: {'skipAuth': skipAuth}),
    );
  }

  Future<Response<T>> put<T>(String path, {Object? data}) {
    return dio.put<T>(path, data: data);
  }

  Never throwFromDio(DioException e, String fallback) {
    final status = e.response?.statusCode;
    throw ApiException(_friendlyMessage(e, status, fallback),
        statusCode: status);
  }

  /// Turns a Dio failure into a short, user-facing sentence. Timeouts and
  /// gateway errors (502/503/504) often return an HTML error page as the body,
  /// so we never surface that — we map them to a plain message instead.
  String _friendlyMessage(DioException e, int? status, String fallback) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The server took too long to respond. Please try again.';
      case DioExceptionType.connectionError:
        return 'Unable to reach the server. Please check your connection.';
      default:
        break;
    }
    if (status == 502 || status == 503 || status == 504) {
      return 'The server is temporarily unavailable. Please try again in a moment.';
    }
    return ApiException.messageFromResponse(e.response?.data, fallback);
  }
}
