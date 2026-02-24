import 'package:flutter_test/flutter_test.dart';
import 'package:myscooter/main.dart';
import 'package:myscooter/service/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Verifica caricamento HomeScreen e Titolo', (WidgetTester tester) async {
    // 1. Inizializziamo le SharedPreferences per i test (Mock)
    SharedPreferences.setMockInitialValues({});

    // 2. Creiamo un'istanza reale di ThemeService
    final themeService = ThemeService();

    // 3. Avviamo l'app passando il themeService (non più null!)
    // Nota: rimuoviamo 'const' perché themeService è un oggetto creato a runtime
    await tester.pumpWidget(MyApp(themeService: themeService));

    // 4. Verifichiamo che il titolo della AppBar sia presente
    // Usiamo find.text('My Scooter') perché è quello che abbiamo messo nella HomeScreen
    expect(find.text('My Scooter'), findsOneWidget);

    // 5. Verifichiamo che non ci sia più il vecchio contatore del template standard
    expect(find.text('0'), findsNothing);
  });
}