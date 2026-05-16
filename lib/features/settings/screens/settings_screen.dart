import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// VERIFICA QUESTO IMPORT: deve puntare a core/providers e non a core/theme
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/theme_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../scooter/widgets/terms_and_conditions_view.dart';

class SettingsScreen extends ConsumerWidget {
  final ThemeService themeService;

  const SettingsScreen({super.key, required this.themeService});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // SEZIONE 1: PROFILO E DATI
          _buildSectionTitle(l10n.profiloTitle.toUpperCase()),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(l10n.profiloTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile'), // Apre la schermata apposita
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.save),
                  title: Text(l10n.backupRestoreTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/backup-restore'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SEZIONE 2: IMPOSTAZIONI APP
          _buildSectionTitle(l10n.settingsTitle.toUpperCase()),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: Text(l10n.themeLabel),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeService.themeMode,
                    underline: const SizedBox(),
                    onChanged: (ThemeMode? newMode) {
                      if (newMode != null) themeService.setThemeMode(newMode);
                    },
                    items: [
                      DropdownMenuItem(value: ThemeMode.system, child: Text(l10n.themeSystem)),
                      DropdownMenuItem(value: ThemeMode.light, child: Text(l10n.themeLight)),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.themeDark)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.languageLabel),
                  trailing: DropdownButton<String>(
                    value: currentLocale?.languageCode ?? '',
                    underline: const SizedBox(),
                    onChanged: (String? newLang) {
                      if (newLang != null) ref.read(localeProvider.notifier).setLocale(newLang);
                    },
                    items: const [
                      DropdownMenuItem(value: '', child: Text("Sistema")),
                      DropdownMenuItem(value: 'it', child: Text("Italiano")),
                      DropdownMenuItem(value: 'en', child: Text("English")),
                      DropdownMenuItem(value: 'es', child: Text("Español")),
                      DropdownMenuItem(value: 'fr', child: Text("Français")),
                      DropdownMenuItem(value: 'de', child: Text("Deutsch")),
                      DropdownMenuItem(value: 'pt', child: Text("Português")),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SEZIONE 3: INFORMAZIONI
          _buildSectionTitle(l10n.informazioni.toUpperCase()),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.versione),
                  trailing: const Text("1.0.0", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(l10n.termini_condizioni),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => const TermsAndConditionsView(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
    );
  }
}