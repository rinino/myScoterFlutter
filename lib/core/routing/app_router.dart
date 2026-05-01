import 'package:go_router/go_router.dart';

import '../../features/rifornimento/models/rifornimento.dart';
import '../../features/rifornimento/screens/add_edit_rifornimento_screen.dart';
import '../../features/rifornimento/screens/refuelings_screen.dart';
import '../../features/rifornimento/screens/rifornimento_detail_screen.dart';
import '../../features/scooter/model/scooter.dart';
import '../../features/scooter/screens/add_edit_scooter_screen.dart';
import '../../features/scooter/screens/home_screen.dart';
import '../../features/scooter/screens/scooter_detail_screen.dart';
import '../../features/settings/screens/backup_restore_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../theme/theme_service.dart';
import 'package:myscooter/features/rifornimento/screens/location_picker_screen.dart';
import 'package:myscooter/features/manutenzione/models/manutenzione.dart';
import 'package:myscooter/features/manutenzione/screens/maintenance_list_screen.dart';
import 'package:myscooter/features/manutenzione/screens/add_edit_maintenance_screen.dart';
import 'package:myscooter/features/manutenzione/screens/maintenance_detail_screen.dart';

import 'package:myscooter/features/documenti/models/documento.dart';
import 'package:myscooter/features/documenti/screens/documento_detail_screen.dart';
import 'package:myscooter/features/documenti/screens/add_edit_documento_screen.dart';

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
      GoRoute(
        path: '/backup-restore',
        builder: (context, state) => const BackupRestoreScreen(),
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
      GoRoute(
        path: '/location-picker',
        name: 'location-picker',
        builder: (context, state) {
          // Estraiamo le coordinate iniziali se ci sono (passate come 'extra')
          final extra = state.extra as Map<String, double?>?;
          final lat = extra?['lat'];
          final lon = extra?['lon'];

          return LocationPickerScreen(initialLat: lat, initialLon: lon);
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
      GoRoute(
        path: '/refuelings/:scooterId',
        builder: (context, state) {
          final scooter = state.extra as Scooter;
          return RefuelingsScreen(scooter: scooter);
        },
      ),
      // Rotta 5: Aggiungi o Modifica Rifornimento (passiamo l'id nello URL e l'oggetto in extra)
      GoRoute(
        path: '/add-edit-rifornimento/:scooterId',
        name: 'add-edit-rifornimento',
        builder: (context, state) {
          final scooterId = int.parse(state.pathParameters['scooterId']!);
          final rifornimento = state.extra as Rifornimento?;
          return AddEditRifornimentoScreen(scooterId: scooterId, rifornimento: rifornimento);
        },
      ),
      // Rotta 6: Dettaglio Rifornimento
      GoRoute(
        path: '/rifornimento-detail/:scooterId',
        name: 'rifornimento-detail',
        builder: (context, state) {
          final scooterId = int.parse(state.pathParameters['scooterId']!);
          final rifornimento = state.extra as Rifornimento;
          return RifornimentoDetailScreen(scooterId: scooterId, rifornimento: rifornimento);
        },
      ),

      // --- ROTTE MANUTENZIONE ---
      GoRoute(
        path: '/maintenance/:scooterId',
        builder: (context, state) {
          final scooter = state.extra as Scooter;
          return MaintenanceListScreen(scooter: scooter);
        },
      ),
      GoRoute(
        path: '/add-edit-maintenance',
        builder: (context, state) {
          // Passiamo sia l'ID dello scooter che l'eventuale manutenzione da modificare
          final extra = state.extra as Map<String, dynamic>;
          final scooterId = extra['scooterId'] as int;
          final manutenzione = extra['manutenzione'] as Manutenzione?;
          return AddEditMaintenanceScreen(scooterId: scooterId, manutenzione: manutenzione);
        },
      ),
      GoRoute(
        path: '/maintenance-detail',
        builder: (context, state) {
          final manutenzione = state.extra as Manutenzione;
          return MaintenanceDetailScreen(manutenzione: manutenzione);
        },
      ),

      // --- ROTTE DOCUMENTI ---
      GoRoute(
        path: '/documento-detail',
        builder: (context, state) {
          final documento = state.extra as Documento;
          return DocumentoDetailScreen(documento: documento);
        },
      ),
      GoRoute(
        path: '/add-edit-documento',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final scooterId = extra['scooterId'] as int;
          final documento = extra['documento'] as Documento?;
          return AddEditDocumentoScreen(scooterId: scooterId, documento: documento);
        },
      ),



    ],
  );
}