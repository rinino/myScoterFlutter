import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/theme_service.dart';


class SettingsScreen extends StatefulWidget {
  final ThemeService themeService;

  const SettingsScreen({super.key, required this.themeService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = "N/D";
  final String _currentYear = DateTime.now().year.toString();

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  // Carica i dati della build (come Bundle.main in Swift)
  Future<void> _initPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = "${info.version} (${info.buildNumber})";
      });
    } catch (e) {
      debugPrint("Errore nel recupero versione: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
        centerTitle: true,
        // Tasto "Fatto" in alto a destra come su iOS
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fatto',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.themeService,
        builder: (context, _) {
          return ListView(
            children: [
              // --- SEZIONE ASPETTO ---
              _buildSectionHeader("ASPETTO"),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: _buildThemePicker(),
              ),
              _buildSectionFooter(
                  "Scegli se preferisci un'interfaccia chiara, scura o se vuoi seguire le impostazioni automatiche del tuo dispositivo."
              ),

              const SizedBox(height: 10),

              // --- SEZIONE INFORMAZIONI E LEGALE ---
              _buildSectionHeader("INFORMAZIONI"),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    // Riga Versione
                    _buildInfoTile(Icons.info_outline, "Versione", _appVersion),
                    const Divider(height: 1, indent: 55),

                    // Riga Copyright
                    _buildInfoTile(Icons.copyright, "Copyright", "$_currentYear - MyScooter App"),
                    const Divider(height: 1, indent: 55),

                    // Riga Termini e Condizioni (Navigabile)
                    ListTile(
                      leading: const Icon(Icons.description, color: Colors.blue),
                      title: const Text("Termini e Condizioni"),
                      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                      onTap: () => _showTermsModal(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGETS DI SUPPORTO ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildSectionFooter(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  Widget _buildThemePicker() {
    return ListTile(
      leading: const Icon(Icons.palette, color: Colors.blue),
      title: const Text("Aspetto"),
      trailing: DropdownButton<ThemeMode>(
        value: widget.themeService.themeMode,
        underline: const SizedBox(),
        icon: const Icon(Icons.unfold_more, size: 20),
        onChanged: (ThemeMode? newMode) {
          if (newMode != null) widget.themeService.setTheme(newMode);
        },
        items: const [
          DropdownMenuItem(value: ThemeMode.system, child: Text("Sistema")),
          DropdownMenuItem(value: ThemeMode.light, child: Text("Chiaro")),
          DropdownMenuItem(value: ThemeMode.dark, child: Text("Scuro")),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: Text(value, style: const TextStyle(color: Colors.grey, fontSize: 15)),
    );
  }

  void _showTermsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TermsAndConditionsView(),
    );
  }
}

// --- SOTTO-VISTA TERMINI E CONDIZIONI (Sheet) ---

class TermsAndConditionsView extends StatelessWidget {
  const TermsAndConditionsView({super.key});

  final String _urlSito = "https://rinino.github.io/myScooterSite/";

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header della modale
          AppBar(
            title: const Text("Legale"),
            centerTitle: true,
            automaticallyImplyLeading: false,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Fatto", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Icon(Icons.document_scanner, size: 80, color: Colors.blue),
                  const SizedBox(height: 25),
                  const Text(
                    "Maggiori Informazioni",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Per conoscere i dettagli sulla gestione dei dati e i termini d'uso, visita il nostro sito ufficiale.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 40),

                  // Pulsante Blu con Ombra
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(_urlSito);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.open_in_new, color: Colors.white),
                      label: const Text("Leggi sul sito", style: TextStyle(fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
                  const Text(
                    "L'app non raccoglie dati personali su server esterni. Tutto viene salvato localmente.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}