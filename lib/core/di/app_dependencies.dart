import '../../core/api/auth_api.dart';
import '../../core/api/quote_approvals_api.dart';
import '../../core/network/api_client.dart';
import '../../core/network/token_storage.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/quote_repository.dart';
import '../../services/session_service.dart';

/// Single place to construct and access API-backed services.
class AppDependencies {
  AppDependencies._();

  static AppDependencies? _instance;

  static AppDependencies get instance {
    final existing = _instance;
    if (existing != null) return existing;
    final created = AppDependencies._();
    _instance = created;
    return created;
  }

  final TokenStorage tokenStorage = TokenStorage();
  late final ApiClient apiClient = ApiClient(tokenStorage: tokenStorage);
  late final AuthApi authApi = AuthApi(apiClient);
  late final QuoteApprovalsApi quoteApprovalsApi =
      QuoteApprovalsApi(apiClient);

  late final SessionService sessionService =
      SessionService(tokenStorage: tokenStorage);

  late final AuthRepository authRepository = AuthRepository(
    authApi: authApi,
    sessionService: sessionService,
    tokenStorage: tokenStorage,
  );

  late final QuoteRepository quoteRepository = QuoteRepository(
    quoteApi: quoteApprovalsApi,
  );

  /// Call on app start to restore session from secure storage.
  Future<void> initialize() => sessionService.restoreSession();
}
