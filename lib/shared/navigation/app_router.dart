import 'package:flutter/material.dart';
import '../../data/models/quote_model.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/quote_detail/screens/quote_detail_screen.dart';
import '../widgets/main_screen.dart';

class AppRouter {
  AppRouter._();

  static const String login = '/';
  static const String main = '/main';
  static const String quoteDetail = '/quote-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case main:
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
