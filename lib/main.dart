import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preppilot/core/theme/app_theme.dart';
import 'package:preppilot/shared/widgets/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const MainShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}
