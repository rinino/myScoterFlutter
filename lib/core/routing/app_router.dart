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

// Import Documenti e Onboarding
import 'package:myscooter/features/documenti/models/documento.dart';
import 'package:myscooter/features/documenti/screens/documento_detail_screen.dart';
import 'package:myscooter/features/documenti/screens/add_edit_documento_screen.dart';
import 'package:myscooter/features/onboarding/screens/onboarding_screen.dart';

import 'package:myscooter/features/profilo/screens/email_auth_screen.dart';
import 'package:myscooter/features/profilo/screens/edit_profile_screen.dart';

import 'package:myscooter/features/profilo/screens/profile_screen.dart';

GoRouter createRouter(ThemeService themeService, bool hasSeenOnboarding) {
  return GoRouter(
    initialLocation: hasSeenOnboarding ? '/' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(themeService: themeService),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsScreen(themeService: themeService),
      ),
      GoRoute(
        path: '/backup-restore',
        builder: (context, state) => const BackupRestoreScreen(),
      ),
      GoRoute(
        path: '/add-edit-scooter',
        builder: (context, state) {
          final scooter = state.extra as Scooter?;
          return AddEditScooterScreen(scooter: scooter);
        },
      ),
      GoRoute(
        path: '/location-picker',
        name: 'location-picker',
        builder: (context, state) {
          final extra = state.extra as Map<String, double?>?;
          final lat = extra?['lat'];
          final lon = extra?['lon'];
          return LocationPickerScreen(initialLat: lat, initialLon: lon);
        },
      ),
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
      GoRoute(
        path: '/add-edit-rifornimento/:scooterId',
        name: 'add-edit-rifornimento',
        builder: (context, state) {
          // Nessun int.parse!
          final scooterId = state.pathParameters['scooterId']!;
          final rifornimento = state.extra as Rifornimento?;
          return AddEditRifornimentoScreen(scooterId: scooterId, rifornimento: rifornimento);
        },
      ),
      GoRoute(
        path: '/rifornimento-detail/:scooterId',
        name: 'rifornimento-detail',
        builder: (context, state) {
          // Nessun int.parse!
          final scooterId = state.pathParameters['scooterId']!;
          final rifornimento = state.extra as Rifornimento;
          return RifornimentoDetailScreen(scooterId: scooterId, rifornimento: rifornimento);
        },
      ),
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
          final extra = state.extra as Map<String, dynamic>;
          final scooterId = extra['scooterId'] as String;
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
          final scooterId = extra['scooterId'] as String;
          final documento = extra['documento'] as Documento?;
          return AddEditDocumentoScreen(scooterId: scooterId, documento: documento);
        },
      ),
      GoRoute(
        path: '/email-auth',
        builder: (context, state) => const EmailAuthScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),

      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}