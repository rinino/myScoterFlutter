import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:myscooter/features/scooter/providers/scooter_provider.dart';
import '../../../../core/database/backup_manager.dart';
import '../../../../core/providers/message_provider.dart';
import '../../../l10n/app_localizations.dart';

// FIX: Importiamo i componenti del Design System
import 'package:myscooter/core/theme/app_colors.dart';
import 'package:myscooter/core/widgets/glass_background.dart';
import 'package:myscooter/core/widgets/glass_card.dart';

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
      backgroundColor: Colors.transparent, // FIX: Scaffold trasparente
      extendBodyBehindAppBar: true,        // FIX: Effetto vetro sotto l'AppBar
      appBar: AppBar(
        title: Text(l10n.backupRestoreTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue), // Icona back blu
      ),
      body: Stack(
        children: [
          // FIX: Sfondo in vetro globale
          const GlassBackground(
            primaryColor: AppColors.primaryBlue,
            secondaryColor: AppColors.secondaryCyan,
          ),

          SafeArea(
            child: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 24),
                  children: [
                    _buildSectionHeader(l10n.backupSection),
                    GlassCard(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.cloud_upload_outlined, color: AppColors.primaryBlue, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(l10n.backupDesc, style: const TextStyle(fontSize: 15, height: 1.4)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _esporta,
                              icon: const Icon(Icons.upload_file),
                              label: Text(l10n.createBackupBtn, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                                disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    _buildSectionHeader(l10n.restoreSection),
                    GlassCard(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                    l10n.restoreDesc,
                                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15, height: 1.4)
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _ripristina,
                              icon: const Icon(Icons.download),
                              label: Text(l10n.restoreBtn, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                                disabledBackgroundColor: Colors.redAccent.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
      child: Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)
      ),
    );
  }
}