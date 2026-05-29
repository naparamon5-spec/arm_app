import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class AuthService {
  final _repository = AuthRepository();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _repository.login(email: email, password: password);
      if (user != null) {
        _currentUser = user;
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } finally {
      _currentUser = null;
    }
  }
}
