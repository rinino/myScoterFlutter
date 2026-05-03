// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart'; // Necessario per SystemChrome

// FIX: Aggiunto l'import per inizializzare Firebase
import 'package:firebase_core/firebase_core.dart';

// Import corretti per l'architettura
import 'package:myscooter/core/theme/theme_service.dart';
import 'package:myscooter/core/routing/app_router.dart';
import 'package:myscooter/core/providers/locale_provider.dart';

import 'core/notifications/notification_service.dart';
import 'l10n/app_localizations.dart';

import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIX: Inizializza Firebase prima di qualsiasi altra cosa!
  await Firebase.initializeApp();

  // Inizializza notifiche e impostazioni grafiche...
  await NotificationService().init();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // LEGGE LA PREFERENZA DELL'ONBOARDING
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  final themeService = ThemeService();

  // PASSALA AL ROUTER
  final router = createRouter(themeService, hasSeenOnboarding);

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

          localeResolutionCallback: (deviceLocale, supportedLocales) {
            if (deviceLocale != null) {
              for (var locale in supportedLocales) {
                if (locale.languageCode == deviceLocale.languageCode) {
                  return deviceLocale; // Lingua trovata, usa quella del dispositivo!
                }
              }
            }
            // Lingua sconosciuta (es. Olandese, Russo, ecc.), usa l'Inglese di default
            return const Locale('en', '');
          },
        );
      },
    );
  }
}