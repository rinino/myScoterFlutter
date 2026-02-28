// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import corretti per l'architettura
import 'package:myscooter/core/theme/theme_service.dart';
import 'package:myscooter/core/routing/app_router.dart';
import 'package:myscooter/core/providers/locale_provider.dart';

import 'l10n/app_localizations.dart';



void main() async {
  // ADR: Necessario per SharedPreferences e l'inizializzazione nativa
  WidgetsFlutterBinding.ensureInitialized();

  final themeService = ThemeService();
  final router = createRouter(themeService);

  runApp(
    ProviderScope(
      child: MyApp(themeService: themeService, router: router),
    ),
  );
}

// 1. Cambiato in ConsumerWidget per "ascoltare" i provider
class MyApp extends ConsumerWidget {
  final ThemeService themeService;
  final GoRouter router;

  const MyApp({super.key, required this.themeService, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. ASCOLTIAMO il localeProvider.
    // Quando chiamerai .setLocale() nelle impostazioni, questa riga farà scattare il rebuild.
    final selectedLocale = ref.watch(localeProvider);

    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,

          // 3. APPLICHIAMO LA LINGUA DINAMICA
          locale: selectedLocale,

          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,

          themeMode: themeService.themeMode,
          theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorSchemeSeed: Colors.blue
          ),
          darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorSchemeSeed: Colors.blue
          ),

          routerConfig: router,

          // 4. CONFIGURAZIONE DELEGATES (Semplificata)
          localizationsDelegates: AppLocalizations.localizationsDelegates,

          // Legge le lingue supportate dai file .arb (it, en)
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}