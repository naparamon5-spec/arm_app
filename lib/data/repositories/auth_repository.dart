import '../../core/api/auth_api.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/token_storage.dart';
import '../../services/session_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthApi authApi;
  final SessionService sessionService;
  final TokenStorage tokenStorage;

  AuthRepository({
    required this.authApi,
    required this.sessionService,
    required this.tokenStorage,
  });

  Future<UserModel> login({
    required String userId,
    required String password,
  }) async {
    final data = await authApi.login(userId: userId, password: password);
    final accessToken = data['access_token']?.toString();
    final refreshToken = data['refresh_token']?.toString();
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      throw const ApiException('Login failed');
    }

    await sessionService.setSession(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    // Keep the just-entered credentials in memory so the Profile screen can
    // enable biometric login without re-prompting for the password.
    sessionService.lastUserId = userId;
    sessionService.lastPassword = password;

    // If biometric login is already enabled, refresh the stored credentials so
    // a later password change keeps biometric login working.
    if (await tokenStorage.isBiometricEnabled()) {
      await tokenStorage.setBiometricCredentials(
        userId: userId,
        password: password,
      );
    }

    return sessionService.currentUser!;
  }

  Future<void> logout() async {
    final refresh = await tokenStorage.refreshToken;
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await authApi.logout(refreshToken: refresh);
      } catch (_) {
        // Clear local session even if revoke fails.
      }
    }
    await sessionService.clearSession();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return authApi.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
