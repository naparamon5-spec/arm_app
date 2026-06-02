import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/network/api_exception.dart';

class AuthController extends ChangeNotifier {
  final _authRepo = AppDependencies.instance.authRepository;
  final _session = AppDependencies.instance.sessionService;

  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberDevice = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get rememberDevice => _rememberDevice;

  void setRememberDevice(bool value) {
    _rememberDevice = value;
    _session.setRememberDevice(value);
    notifyListeners();
  }

  Future<void> login({
    required String userId,
    required String password,
    required VoidCallback onSuccess,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _session.setRememberDevice(_rememberDevice);
    notifyListeners();

    try {
      await _authRepo.login(userId: userId, password: password);
      onSuccess();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Login failed. Please check your credentials.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
