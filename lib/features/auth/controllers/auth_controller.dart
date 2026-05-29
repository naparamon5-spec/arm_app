import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';

class AuthController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberDevice = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get rememberDevice => _rememberDevice;

  void setRememberDevice(bool value) {
    _rememberDevice = value;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
    required VoidCallback onSuccess,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      if (email == AppStrings.mockEmail && password == AppStrings.mockPassword) {
        onSuccess();
      } else {
        _errorMessage = AppStrings.loginInvalidCredentials;
      }
    } catch (_) {
      _errorMessage = AppStrings.loginFailed;
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
