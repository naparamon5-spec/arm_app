import 'package:flutter/material.dart';
import '../../data/models/quote_model.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/quote_detail/screens/quote_detail_screen.dart';
import '../widgets/main_screen.dart';

class AppRouter {
  AppRouter._();

  /// App-wide navigator, so non-widget code (e.g. the API client on session
  /// expiry) can navigate without a BuildContext.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String main = '/main';
  static const String dashboard = '/dashboard';
  static const String quoteDetail = '/quote-detail';
  static const String changePassword = '/change-password';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case main:
      case dashboard:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case quoteDetail:
        final quote = settings.arguments as QuoteModel;
        return MaterialPageRoute(
          builder: (_) => QuoteDetailScreen(quote: quote),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
