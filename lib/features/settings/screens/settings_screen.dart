import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:myscooter/core/auth/auth_manager.dart';
import 'package:myscooter/core/providers/message_provider.dart';
import 'package:myscooter/features/scooter/providers/scooter_provider.dart';
import 'package:myscooter/core/theme/locale_provider.dart'; // Assicurati che esista
import '../../../core/theme/theme_service.dart';
import '../../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  final ThemeService themeService;

  const SettingsScreen({super.key, required this.themeService});

  Future<void> _handleLogin(BuildContext context, WidgetRef ref, Future<bool> Function() loginMethod) async {
    final l10n = AppLocalizations.of(context)!;

    // Popup di avviso sovrascrittura
    final bool? wantsToProceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.attenzioneSovrascritturaTitolo)),
            ],
          ),
          content: Text(l10n.attenzioneSovrascritturaMessaggio),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.annulla, style: const TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.procedi),
            ),
          ],
        );
      },
    );

    if (wantsToProceed != true) return;

    final success = await loginMethod();

    if (success) {
      await ref.read(scooterListProvider.notifier).refreshScooters();
      if (context.mounted) {
        ref.read(messageProvider.notifier).show(l10n.loginSuccess, type: MessageType.success);
      }
    } else {
      if (context.mounted) {
        ref.read(messageProvider.notifier).show(l10n.loginError, type: MessageType.error);
      }
    }
  }

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
          // SEZIONE PROFILO
          _buildSectionTitle(l10n.profiloTitle.toUpperCase()),
          const SizedBox(height: 8),
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              final isAnonymous = user == null || user.isAnonymous;

              return Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isAnonymous
                      ? _buildGuestView(context, ref, l10n)
                      : _buildUserView(context, ref, l10n, user!),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // SEZIONE IMPOSTAZIONI APP
          _buildSectionTitle(l10n.settingsTitle.toUpperCase()),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                // TEMA
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
                // LINGUA
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.languageLabel),
                  trailing: DropdownButton<String>(
                    value: currentLocale?.languageCode ?? '',
                    underline: const SizedBox(),
                    onChanged: (String? newLang) {
                      if (newLang != null) {
                        ref.read(localeProvider.notifier).setLocale(newLang);
                      }
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
                // BACKUP
                ListTile(
                  leading: const Icon(Icons.save),
                  title: Text(l10n.backupRestoreTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/backup-restore'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12));
  }

  Widget _buildGuestView(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.utenteOspite, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(l10n.datiLocali, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _handleLogin(context, ref, AuthManager.shared.signInWithGoogle),
          icon: const Icon(Icons.account_circle),
          label: Text(l10n.accediGoogle),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45), backgroundColor: Colors.white, foregroundColor: Colors.black),
        ),
        const SizedBox(height: 8),
        if (Platform.isIOS) ...[
          ElevatedButton.icon(
            onPressed: () => _handleLogin(context, ref, AuthManager.shared.signInWithApple),
            icon: const Icon(Icons.apple),
            label: Text(l10n.accediApple),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45), backgroundColor: Colors.black, foregroundColor: Colors.white),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: () => context.push('/email-auth'),
          icon: const Icon(Icons.email_outlined),
          label: Text(l10n.accediEmail),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
        ),
      ],
    );
  }

  Widget _buildUserView(BuildContext context, WidgetRef ref, AppLocalizations l10n, User user) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              backgroundColor: Colors.blue,
              child: user.photoURL == null ? Text(user.email?[0].toUpperCase() ?? 'U', style: const TextStyle(color: Colors.white)) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user.displayName != null)
                    Text(user.displayName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(user.email ?? l10n.cloudUser, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => context.push('/edit-profile'),
          icon: const Icon(Icons.edit),
          label: Text(l10n.modificaProfilo),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45), backgroundColor: Colors.blue.withValues(alpha: 0.1), foregroundColor: Colors.blue, elevation: 0),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () async {
            await AuthManager.shared.signOut();
            await ref.read(scooterListProvider.notifier).refreshScooters();
            if (context.mounted) ref.read(messageProvider.notifier).show(l10n.logoutSuccess);
          },
          icon: const Icon(Icons.logout),
          label: Text(l10n.esci),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
      ],
    );
  }
}