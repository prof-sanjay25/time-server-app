import 'package:flutter/material.dart';

import 'constants/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash/splash_screen.dart';

class TimeServerApp extends StatelessWidget {
  const TimeServerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
    );
  }
}
