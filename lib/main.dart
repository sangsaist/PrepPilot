import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preppilot/core/theme/app_theme.dart';
import 'package:preppilot/shared/widgets/main_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preppilot/shared/widgets/onboarding_screen.dart';
import 'package:preppilot/features/notifications/service/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(
    const ProviderScope(
      child: PrepPilotApp(),
    ),
  );
}

class PrepPilotApp extends StatelessWidget {
  const PrepPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrepPilot',
      theme: AppTheme.lightTheme,
      home: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          final onboarded = snapshot.data!.getBool('onboarded') ?? false;
          return onboarded ? const MainShell() : const OnboardingScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
