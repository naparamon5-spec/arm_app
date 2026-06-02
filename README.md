# Ardent Resource Management (ARM)

Flutter mobile app for quote approvals, connected to the Quote Approval API.

## API integration

| Layer | Location | Purpose |
|-------|----------|---------|
| Config | `lib/core/config/api_config.dart` | Base URL, timeouts, page size |
| Routes | `lib/core/api/api_paths.dart` | All endpoint paths (see `docs/API.md`) |
| HTTP | `lib/core/network/api_client.dart` | Dio client, Bearer auth, token refresh |
| Auth API | `lib/core/api/auth_api.dart` | Login, logout, refresh, change password |
| Quotes API | `lib/core/api/quote_approvals_api.dart` | List, detail, approve |
| DI | `lib/core/di/app_dependencies.dart` | Single entry for repositories |
| Repositories | `lib/data/repositories/` | App-facing data access |
| Mappers | `lib/data/mappers/quote_mapper.dart` | API JSON → domain models |

**Base URL:** `https://quote-approval-api.ardentnetworks.com.ph`

Full endpoint reference: [docs/API.md](docs/API.md)

## Run

```bash
flutter pub get
flutter run
```

Sign in with your MIS **User ID** and password. Tokens are stored securely when **Remember Me** is enabled.
