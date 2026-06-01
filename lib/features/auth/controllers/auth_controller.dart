import 'package:flutter/material.dart';

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
    required String userId,
    required String password,
    required VoidCallback onSuccess,
  }) async {
    const validUserId = 'CEDRICK-A';
    const validPassword = 'Password123.';

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      if (userId == validUserId && password == validPassword) {
        onSuccess();
      } else {
        _errorMessage = 'Invalid User ID or password. Please try again.';
      }
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
