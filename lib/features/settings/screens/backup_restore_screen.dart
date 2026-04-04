import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:myscooter/core/providers/core_providers.dart';
import 'package:myscooter/features/scooter/providers/scooter_provider.dart';
import '../../../../core/database/backup_manager.dart';
import '../../../../core/providers/message_provider.dart';
import '../../../l10n/app_localizations.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isLoading = false;

  Future<void> _esporta() async {
    setState(() => _isLoading = true);
    try {
      // FIX: Passato il context per permettere al BackupManager di leggere le traduzioni
      await BackupManager.exportBackup(context);
    } catch (e) {
      if (mounted) {
        ref.read(messageProvider.notifier).show(
            AppLocalizations.of(context)!.errorBackup,
            type: MessageType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _ripristina() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      final dbHelper = ref.read(databaseProvider);

      // Passiamo il dbHelper al manager per chiuderlo in sicurezza
      final success = await BackupManager.importBackup(dbHelper);

      if (success) {
        debugPrint("✅ [UI] Backup ripristinato sul FileSystem. Riavvio i provider...");

        // 1. Invalida il DatabaseHelper in modo che al prossimo giro lo ricrei aprendo i nuovi file
        ref.invalidate(databaseProvider);

        // 2. Mettiamo un ritardo abbondante. Il file system di iOS/Android ha bisogno
        // di qualche istante prima che SQLite riesca ad acquisire il nuovo lock.
        await Future.delayed(const Duration(milliseconds: 1500));

        // 3. Forziamo l'aggiornamento degli scooter (che userà la nuova istanza DB)
        await ref.read(scooterListProvider.notifier).refreshScooters();

        if (mounted) {
          ref.read(messageProvider.notifier).show(l10n.restoreSuccess, type: MessageType.success);

          // 4. Navigazione brutale alla home.
          // Invece di `context.go('/')`, che potrebbe mantenere lo stack,
          // preferiamo un pushReplacement o go per resettare.
          context.go('/');
        }
      } else {
        if (mounted) {
          ref.read(messageProvider.notifier).show(l10n.errorRestore, type: MessageType.error);
        }
      }
    } catch (e) {
      debugPrint("❌ [UI] ERRORE RESTORE: $e");
      if (mounted) {
        ref.read(messageProvider.notifier).show(l10n.errorRestore, type: MessageType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.backupRestoreTitle),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 24),
            children: [
              // BOX ESPORTAZIONE
              Text(l10n.backupSection, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.backupDesc, style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _esporta, // Disabilita se carica
                          icon: const Icon(Icons.upload_file),
                          label: Text(l10n.createBackupBtn),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.blue.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // BOX RIPRISTINO
              Text(l10n.restoreSection, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Colors.red.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.redAccent, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(child: Text(l10n.restoreDesc, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _ripristina, // Disabilita se carica
                          icon: const Icon(Icons.download),
                          label: Text(l10n.restoreBtn),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.red.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}