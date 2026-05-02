import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      // FIX: BackupManager.importBackup ora gestisce direttamente Firestore! Non serve passare dbHelper
      final success = await BackupManager.importBackup();

      if (success) {
        await Future.delayed(const Duration(milliseconds: 1500));
        await ref.read(scooterListProvider.notifier).refreshScooters();

        if (mounted) {
          ref.read(messageProvider.notifier).show(l10n.restoreSuccess, type: MessageType.success);
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
                          onPressed: _isLoading ? null : _esporta,
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
                          onPressed: _isLoading ? null : _ripristina,
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