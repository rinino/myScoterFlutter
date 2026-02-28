import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Aggiunto per Riverpod
import 'package:myscooter/main.dart';
import 'package:myscooter/core/theme/theme_service.dart';
import 'package:myscooter/core/routing/app_router.dart'; // 2. Aggiunto per il Router
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Verifica caricamento HomeScreen e Titolo', (WidgetTester tester) async {
    // 1. Inizializziamo le SharedPreferences per i test (Mock)
    SharedPreferences.setMockInitialValues({});

    // 2. Creiamo un'istanza reale di ThemeService
    final themeService = ThemeService();

    // 3. Creiamo l'istanza del router che abbiamo definito in app_router.dart
    final router = createRouter(themeService);

    // 4. Avviamo l'app avvolgendola in ProviderScope e passando il router valido
    await tester.pumpWidget(
      ProviderScope(
        child: MyApp(
          themeService: themeService,
          router: router, // Passiamo il router vero!
        ),
      ),
    );

    // 5. IMPORTANTE: Con go_router e i Provider dobbiamo aspettare che la UI si "assesti"
    await tester.pumpAndSettle();

    // 6. Verifichiamo che il titolo della AppBar sia presente
    expect(find.text('My Scooter'), findsOneWidget);

    // 7. Verifichiamo che non ci sia più il vecchio contatore del template standard
    expect(find.text('0'), findsNothing);
  });
}