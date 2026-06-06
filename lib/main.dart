// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart'; // Necessario per SystemChrome

// Inizializzazione Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // FIX: Necessario per la persistenza offline!

// Import corretti per l'architettura
import 'package:myscooter/core/theme/theme_service.dart';
import 'package:myscooter/core/routing/app_router.dart';
import 'package:myscooter/core/providers/locale_provider.dart';

// FIX: Importiamo il nostro nuovo file dei colori centralizzato
import 'package:myscooter/core/theme/app_colors.dart';

import 'core/notifications/notification_service.dart';
import 'l10n/app_localizations.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza Firebase prima di qualsiasi altra cosa!
  await Firebase.initializeApp();

  // FIX: IL TEST DEL GARAGE - Abilitiamo la persistenza offline di Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Mantiene i dati localmente senza limiti di spazio
  );

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
            // FIX: Ora usiamo il blu del nostro Design System
            colorSchemeSeed: AppColors.primaryBlue,
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
            // FIX: Ora usiamo il blu del nostro Design System
            colorSchemeSeed: AppColors.primaryBlue,
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