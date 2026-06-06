import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/theme_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../scooter/widgets/terms_and_conditions_view.dart';

// FIX: Importiamo i componenti del Design System e il provider della valuta
import 'package:myscooter/core/theme/app_colors.dart';
import 'package:myscooter/core/widgets/glass_background.dart';
import 'package:myscooter/core/widgets/glass_card.dart';
import 'package:myscooter/core/providers/currency_provider.dart'; // Assicurati che il path sia corretto

class SettingsScreen extends ConsumerWidget {
  final ThemeService themeService;

  const SettingsScreen({super.key, required this.themeService});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final currentCurrency = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.settingsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const GlassBackground(
            primaryColor: AppColors.primaryBlue,
            secondaryColor: AppColors.secondaryCyan,
          ),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // SEZIONE 1: PROFILO E DATI
                _buildSectionTitle(l10n.profiloTitle.toUpperCase()),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person, color: AppColors.primaryBlue),
                        title: Text(l10n.profiloTitle, style: const TextStyle(fontWeight: FontWeight.w500)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () => context.push('/profile'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.save, color: AppColors.primaryBlue),
                        title: Text(l10n.backupRestoreTitle, style: const TextStyle(fontWeight: FontWeight.w500)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () => context.push('/backup-restore'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // SEZIONE 2: IMPOSTAZIONI APP
                _buildSectionTitle(l10n.settingsTitle.toUpperCase()),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      // Cambio Tema
                      ListTile(
                        leading: const Icon(Icons.color_lens, color: AppColors.primaryBlue),
                        title: Text(l10n.themeLabel, style: const TextStyle(fontWeight: FontWeight.w500)),
                        trailing: DropdownButton<ThemeMode>(
                          value: themeService.themeMode,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.expand_more, color: Colors.grey),
                          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16),
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

                      // Cambio Lingua
                      ListTile(
                        leading: const Icon(Icons.language, color: AppColors.primaryBlue),
                        title: Text(l10n.languageLabel, style: const TextStyle(fontWeight: FontWeight.w500)),
                        trailing: DropdownButton<String>(
                          value: currentLocale?.languageCode ?? '',
                          underline: const SizedBox(),
                          icon: const Icon(Icons.expand_more, color: Colors.grey),
                          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16),
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
                      const Divider(height: 1),

                      // FIX: Selettore della Valuta integrato
                      ListTile(
                        leading: const Icon(Icons.payments, color: AppColors.primaryBlue),
                        title: const Text("Valuta", style: TextStyle(fontWeight: FontWeight.w500)),
                        trailing: DropdownButton<String>(
                          value: currentCurrency,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.expand_more, color: Colors.grey),
                          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16),
                          onChanged: (String? newCurrency) {
                            if (newCurrency != null) {
                              ref.read(currencyProvider.notifier).setCurrency(newCurrency);
                            }
                          },
                          items: const [
                            DropdownMenuItem(value: '€', child: Text('Euro (€)')),
                            DropdownMenuItem(value: '\$', child: Text('Dollaro (\$)')),
                            DropdownMenuItem(value: '£', child: Text('Sterlina (£)')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // SEZIONE 3: INFORMAZIONI
                _buildSectionTitle(l10n.informazioni.toUpperCase()),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline, color: AppColors.primaryBlue),
                        title: Text(l10n.versione, style: const TextStyle(fontWeight: FontWeight.w500)),
                        trailing: const Text("1.0.0", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.description, color: AppColors.primaryBlue),
                        title: Text(l10n.termini_condizioni, style: const TextStyle(fontWeight: FontWeight.w500)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13, letterSpacing: 1.0)
      ),
    );
  }
}