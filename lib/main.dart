// lib/main.dart
import 'package:flutter/material.dart';
import 'package:myscooter/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definiamo il colore personalizzato una volta
    const Color customTitleColor = Color(0xFF00BCD4); // 0xFF seguito dal codice esadecimale

    return MaterialApp(
      title: 'I Miei Scooter',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.blue,
          onPrimary: Colors.white,
          secondary: Colors.cyanAccent,
          onSecondary: Colors.black,
          surface: Colors.black,
          onSurface: Colors.white,
          primaryContainer: Colors.black,
          onPrimaryContainer: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Colors.black,
          surfaceTintColor: Colors.black,
        ),
        listTileTheme: const ListTileThemeData(
          textColor: Colors.white,
          subtitleTextStyle: TextStyle(color: Colors.white70),
        ),
        // --- QUI È LA MODIFICA: Colore per i titoli nel TextTheme ---
        textTheme: TextTheme( // Rimosso 'const' perché il colore del titolo è dinamico
          // Stili che tipicamente rappresentano i titoli (headline, title)
          displayLarge: const TextStyle(color: Colors.white),
          displayMedium: const TextStyle(color: Colors.white),
          displaySmall: const TextStyle(color: Colors.white),
          headlineLarge: const TextStyle(color: customTitleColor), // Titoli più grandi
          headlineMedium: TextStyle(color: customTitleColor),    // "I Miei Scooter" usa questo
          headlineSmall: const TextStyle(color: customTitleColor), // Titoli più piccoli
          titleLarge: const TextStyle(color: customTitleColor),   // Altri titoli
          titleMedium: const TextStyle(color: customTitleColor),
          titleSmall: const TextStyle(color: customTitleColor),

          // Altri stili di testo rimangono bianchi
          bodyLarge: const TextStyle(color: Colors.white),
          bodyMedium: const TextStyle(color: Colors.white),
          bodySmall: const TextStyle(color: Colors.white),
          labelLarge: const TextStyle(color: Colors.white),
          labelMedium: const TextStyle(color: Colors.white),
          labelSmall: const TextStyle(color: Colors.white),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}