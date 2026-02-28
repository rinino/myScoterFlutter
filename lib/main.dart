// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/routing/app_router.dart';
import 'core/theme/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeService = ThemeService();
  final router = createRouter(themeService); // 1. Inizializziamo il router

  runApp(
    ProviderScope(
      child: MyApp(themeService: themeService, router: router), // 2. Lo passiamo all'app
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;
  final GoRouter router; // Riceviamo il router

  const MyApp({super.key, required this.themeService, required this.router});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'My Scooter',
          themeMode: themeService.themeMode,
          theme: ThemeData(useMaterial3: true, brightness: Brightness.light, colorSchemeSeed: Colors.blue),
          darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: Colors.blue),

          routerConfig: router, // 4. Assegniamo la configurazione
        );
      },
    );
  }
}