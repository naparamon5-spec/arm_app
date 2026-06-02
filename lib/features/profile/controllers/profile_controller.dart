import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/user_model.dart';

class ProfileController extends ChangeNotifier {
  final _authRepo = AppDependencies.instance.authRepository;
  final _session = AppDependencies.instance.sessionService;

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _session.restoreSession();
      _user = _session.currentUser;
      if (_user == null) {
        _errorMessage = 'Session expired. Please sign in again.';
      }
    } catch (_) {
      _errorMessage = 'Failed to load profile.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required VoidCallback onSuccess,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      onSuccess();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Password change failed. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut({required VoidCallback onSuccess}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepo.logout();
      onSuccess();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Sign out failed. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
