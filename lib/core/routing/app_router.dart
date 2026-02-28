import 'package:go_router/go_router.dart';

import '../../features/rifornimento/models/rifornimento.dart';
import '../../features/rifornimento/screens/add_edit_rifornimento_screen.dart';
import '../../features/rifornimento/screens/rifornimento_detail_screen.dart';
import '../../features/scooter/model/scooter.dart';
import '../../features/scooter/screens/add_edit_scooter_screen.dart';
import '../../features/scooter/screens/home_screen.dart';
import '../../features/scooter/screens/scooter_detail_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../theme/theme_service.dart';

// Creiamo una funzione che restituisce il router configurato
GoRouter createRouter(ThemeService themeService) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Rotta 1: Home
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(themeService: themeService),
      ),
      // Rotta 2: Impostazioni
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsScreen(themeService: themeService),
      ),
      // Rotta 3: Aggiungi o Modifica Scooter
      GoRoute(
        path: '/add-edit-scooter',
        builder: (context, state) {
          // Recuperiamo l'eventuale scooter passato come 'extra' per la modifica
          final scooter = state.extra as Scooter?;
          return AddEditScooterScreen(scooter: scooter);
        },
      ),
      // Rotta 4: Dettaglio Scooter
      GoRoute(
        path: '/scooter-detail',
        builder: (context, state) {
          final scooter = state.extra as Scooter;
          return ScooterDetailScreen(scooter: scooter);
        },
      ),
      // Rotta 5: Aggiungi o Modifica Rifornimento (passiamo l'id nello URL e l'oggetto in extra)
      GoRoute(
        path: '/add-edit-rifornimento/:scooterId',
        builder: (context, state) {
          final scooterId = int.parse(state.pathParameters['scooterId']!);
          final rifornimento = state.extra as Rifornimento?;
          return AddEditRifornimentoScreen(scooterId: scooterId, rifornimento: rifornimento);
        },
      ),
      // Rotta 6: Dettaglio Rifornimento
      GoRoute(
        path: '/rifornimento-detail/:scooterId',
        builder: (context, state) {
          final scooterId = int.parse(state.pathParameters['scooterId']!);
          final rifornimento = state.extra as Rifornimento;
          return RifornimentoDetailScreen(scooterId: scooterId, rifornimento: rifornimento);
        },
      ),
    ],
  );
}