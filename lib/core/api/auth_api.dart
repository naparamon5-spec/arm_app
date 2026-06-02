import 'package:dio/dio.dart';

import '../network/api_client.dart';
import 'api_paths.dart';

class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  Future<Map<String, dynamic>> login({
    required String userId,
    required String password,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        ApiPaths.authLogin,
        data: {'user_id': userId, 'password': password},
        skipAuth: true,
      );
      return Map<String, dynamic>.from(response.data ?? {});
    } on DioException catch (e) {
      _client.throwFromDio(e, 'Login failed');
    }
  }

  Future<Map<String, dynamic>> refresh({required String refreshToken}) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        ApiPaths.authRefresh,
        data: {'refresh_token': refreshToken},
        skipAuth: true,
      );
      return Map<String, dynamic>.from(response.data ?? {});
    } on DioException catch (e) {
      _client.throwFromDio(e, 'Session refresh failed');
    }
  }

  Future<void> logout({required String refreshToken}) async {
    try {
      await _client.post(
        ApiPaths.authLogout,
        data: {'refresh_token': refreshToken},
        skipAuth: true,
      );
    } on DioException catch (e) {
      _client.throwFromDio(e, 'Logout failed');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _client.post(
        ApiPaths.authChangePassword,
        data: {
          'currentPassword': currentPassword,
          'NewPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      _client.throwFromDio(e, 'Password change failed');
    }
  }
}
