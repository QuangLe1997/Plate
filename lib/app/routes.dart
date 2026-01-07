import 'package:flutter/material.dart';

import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/scan/scan_screen.dart';
import '../presentation/screens/history/history_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String scan = '/scan';
  static const String history = '/history';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case scan:
        return MaterialPageRoute(builder: (_) => const ScanScreen());
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
