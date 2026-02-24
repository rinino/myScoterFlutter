import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart'; // Risolve 'WidgetsFlutterBinding' e 'runApp'
import 'package:myscooter/screens/home_screen.dart';
import 'package:myscooter/service/theme_service.dart'; // Risolve 'HomeScreen'


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializziamo il servizio temi
  final themeService = ThemeService();

  runApp(MyApp(themeService: themeService));
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;
  const MyApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder ricostruisce MaterialApp ogni volta che il tema cambia
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Scooter',
          // Configurazione Temi
          themeMode: themeService.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: Colors.blue,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.blue,
          ),
          // Passiamo il servizio alla HomeScreen per poterlo poi passare ai Settings
          home: HomeScreen(themeService: themeService),
        );
      },
    );
  }
}