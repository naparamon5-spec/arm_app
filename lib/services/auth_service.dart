import '../core/di/app_dependencies.dart';
import '../data/models/user_model.dart';

/// Facade for auth state used by legacy call sites.
class AuthService {
  final _session = AppDependencies.instance.sessionService;

  UserModel? get currentUser => _session.currentUser;
  bool get isLoggedIn => _session.isLoggedIn;
}
