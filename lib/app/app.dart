import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/onboarding/presentation/screens/splash_screen.dart';

/// Root app. Callers: main.dart.
/// User: "the corners on the bottom of the app is having curves it should not have this"
class SnipRApp extends StatelessWidget {
  const SnipRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snipr',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      builder: (context, child) {
        return ColoredBox(
          color: AppTheme.darkTheme.scaffoldBackgroundColor,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}
