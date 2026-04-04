// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart'; // Necessario per SystemChrome

// Import corretti per l'architettura
import 'package:myscooter/core/theme/theme_service.dart';
import 'package:myscooter/core/routing/app_router.dart';
import 'package:myscooter/core/providers/locale_provider.dart';

import 'l10n/app_localizations.dart';

void main() async {
  // ADR: Necessario per SharedPreferences e l'inizializzazione nativa
  WidgetsFlutterBinding.ensureInitialized();

  // FIX EDGE-TO-EDGE:
  // 1. Abilitiamo la modalità edge-to-edge a livello di sistema.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 2. Impostiamo lo stile iniziale (Barre trasparenti).
  // Flutter 3.10+ e Android 14+ preferiscono la trasparenza gestita dal framework.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  final themeService = ThemeService();
  final router = createRouter(themeService);

  runApp(
    ProviderScope(
      child: MyApp(themeService: themeService, router: router),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final ThemeService themeService;
  final GoRouter router;

  const MyApp({super.key, required this.themeService, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLocale = ref.watch(localeProvider);

    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          locale: selectedLocale,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          themeMode: themeService.themeMode,

          // TEMA CHIARO
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: Colors.blue,
            // FIX: Gestione corretta delle icone status bar nel tema chiaro
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.dark, // Icone nere su sfondo chiaro
                statusBarBrightness: Brightness.light,    // Per iOS
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
            ),
          ),

          // TEMA SCURO
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.blue,
            // FIX: Gestione corretta delle icone status bar nel tema scuro
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.light, // Icone bianche su sfondo scuro
                statusBarBrightness: Brightness.dark,     // Per iOS
                systemNavigationBarIconBrightness: Brightness.light,
              ),
            ),
          ),

          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}