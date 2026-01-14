import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'routes.dart';
import 'theme.dart';
import '../core/constants/strings.dart';
import '../presentation/providers/scan_provider.dart';
import '../presentation/providers/history_provider.dart';
import '../presentation/providers/settings_provider.dart';

// Global RouteObserver for detecting navigation events
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class PlateSnapApp extends StatelessWidget {
  const PlateSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ScanProvider(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          // Schedule settings sync after build phase
          SchedulerBinding.instance.addPostFrameCallback((_) {
            final scanProvider = context.read<ScanProvider>();
            scanProvider.updateSettings(
              confidenceThreshold: settingsProvider.confidenceThreshold,
              autoContinuousScan: settingsProvider.autoContinuousScan,
              soundEnabled: settingsProvider.soundEnabled,
              vibrationEnabled: settingsProvider.vibrationEnabled,
              startupDelayMs: settingsProvider.startupDelayMs,
              confirmationFrames: settingsProvider.confirmationFrames,
            );
          });

          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.generateRoute,
            navigatorObservers: [routeObserver],
          );
        },
      ),
    );
  }
}
