import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes.dart';
import 'theme.dart';
import '../core/constants/strings.dart';
import '../presentation/providers/scan_provider.dart';
import '../presentation/providers/history_provider.dart';
import '../presentation/providers/settings_provider.dart';

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
          // Apply settings to scan provider
          final scanProvider = context.read<ScanProvider>();
          scanProvider.setConfidenceThreshold(settingsProvider.confidenceThreshold);
          scanProvider.setAutoContinuousScan(settingsProvider.autoContinuousScan);
          scanProvider.setSoundEnabled(settingsProvider.soundEnabled);
          scanProvider.setVibrationEnabled(settingsProvider.vibrationEnabled);

          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
