// lib/features/scooter/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/theme_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../scooter/widgets/terms_and_conditions_view.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  final ThemeService themeService;

  const SettingsScreen({super.key, required this.themeService});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = "1.0 (1)";
  final String _currentYear = DateTime.now().year.toString();
  String? _tempLanguageCode;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _tempLanguageCode = ref.read(localeProvider)?.languageCode;
  }

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.impostazioni),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              ref.read(localeProvider.notifier).setLocale(_tempLanguageCode);
              Navigator.pop(context);
            },
            child: Text(
              l10n.fatto,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.themeService,
        builder: (context, _) {
          return ListView(
            children: [
              _buildSectionHeader(l10n.aspetto.toUpperCase()),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: _buildThemePicker(l10n),
              ),
              const SizedBox(height: 10),
              _buildSectionHeader(l10n.lingua.toUpperCase()),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: _buildLanguagePicker(l10n),
              ),
              const SizedBox(height: 10),
              _buildSectionHeader(l10n.informazioni.toUpperCase()),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    _buildInfoTile(Icons.info_outline, l10n.versione, _appVersion),
                    const Divider(height: 1, indent: 55),
                    _buildInfoTile(Icons.copyright, "Copyright", "$_currentYear - MyScooter App"),
                    const Divider(height: 1, indent: 55),
                    ListTile(
                      leading: const Icon(Icons.description, color: Colors.blue),
                      title: Text(l10n.termini_condizioni),
                      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                      onTap: () => _showTermsModal(context),
                    ),
                  ],
                ),
              ),
              _buildSectionFooter(l10n.info_dati),
            ],
          );
        },
      ),
    );
  }

  // --- HELPERS (Inalterati nel funzionamento, tradotti) ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildSectionFooter(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    );
  }

  Widget _buildThemePicker(AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.palette, color: Colors.blue),
      title: Text(l10n.aspetto),
      trailing: DropdownButton<ThemeMode>(
        value: widget.themeService.themeMode,
        underline: const SizedBox(),
        icon: const Icon(Icons.unfold_more, size: 20),
        onChanged: (ThemeMode? newMode) {
          if (newMode != null) widget.themeService.setTheme(newMode);
        },
        items: [
          DropdownMenuItem(value: ThemeMode.system, child: Text(l10n.sistema)),
          DropdownMenuItem(value: ThemeMode.light, child: Text(l10n.chiaro)),
          DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.scuro)),
        ],
      ),
    );
  }

  Widget _buildLanguagePicker(AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.language, color: Colors.blue),
      title: Text(l10n.lingua),
      trailing: DropdownButton<String?>(
        value: _tempLanguageCode,
        underline: const SizedBox(),
        icon: const Icon(Icons.unfold_more, size: 20),
        onChanged: (String? newLang) {
          setState(() => _tempLanguageCode = newLang);
        },
        items: [
          DropdownMenuItem(value: null, child: Text(l10n.sistema)),
          const DropdownMenuItem(value: 'it', child: Text("Italiano")),
          const DropdownMenuItem(value: 'en', child: Text("English")),
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
      builder: (context) => const TermsAndConditionsView(), // Ora importata esternamente
    );
  }
}