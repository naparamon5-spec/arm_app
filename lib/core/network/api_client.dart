import 'package:dio/dio.dart';

import '../api/api_paths.dart';
import '../config/api_config.dart';
import 'api_exception.dart';
import 'token_storage.dart';

/// Shared HTTP client with auth header injection and token refresh.
class ApiClient {
  final TokenStorage tokenStorage;
  late final Dio dio;
  bool _isRefreshing = false;

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

  Future<bool> _tryRefreshToken() async {
    if (_isRefreshing) return false;
    final refresh = await tokenStorage.refreshToken;
    if (refresh == null || refresh.isEmpty) return false;

    _isRefreshing = true;
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
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
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
    final message = ApiException.messageFromResponse(
      e.response?.data,
      fallback,
    );
    throw ApiException(message, statusCode: status);
  }
}
