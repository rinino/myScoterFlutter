import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:myscooter/core/providers/message_provider.dart';
import 'package:myscooter/core/providers/core_providers.dart';

// IMPORT WIDGETS
import '../widgets/scooter_header_image.dart';
import '../widgets/scooter_info_card.dart';
import '../widgets/image_viewer_page.dart';
import '../widgets/refuelings_action_card.dart';
import '../widgets/maintenance_action_card.dart';

import '../../../l10n/app_localizations.dart';
import '../model/scooter.dart';

class ScooterDetailScreen extends ConsumerStatefulWidget {
  final Scooter scooter;

  const ScooterDetailScreen({super.key, required this.scooter});

  @override
  ConsumerState<ScooterDetailScreen> createState() => _ScooterDetailScreenState();
}

class _ScooterDetailScreenState extends ConsumerState<ScooterDetailScreen> {
  bool _isProcessingAction = false;
  late Scooter _currentScooter;

  @override
  void initState() {
    super.initState();
    _currentScooter = widget.scooter;
  }

  void _openImageViewer() {
    if (_currentScooter.imgPath == null || !File(_currentScooter.imgPath!).existsSync()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ImageViewerPage(
          imageFile: File(_currentScooter.imgPath!),
          title: "${_currentScooter.marca} ${_currentScooter.modello}",
          heroTag: 'scooter_image_${_currentScooter.id}',
        ),
      ),
    );
  }

  Future<void> _navigateToEditScooter() async {
    final l10n = AppLocalizations.of(context)!;
    // Supponiamo che la schermata di modifica restituisca lo scooter aggiornato
    final Scooter? updatedScooter = await context.push<Scooter?>('/add-edit-scooter', extra: _currentScooter);

    if (updatedScooter != null) {
      setState(() => _isProcessingAction = true);
      try {
        await ref.read(scooterRepoProvider).updateScooter(updatedScooter);
        if (mounted) {
          setState(() => _currentScooter = updatedScooter);
          ref.read(messageProvider.notifier).show(l10n.scooterUpdated, type: MessageType.success);
        }
      } catch (e) {
        if (mounted) {
          ref.read(messageProvider.notifier).show(l10n.errorUpdating, type: MessageType.error);
        }
      } finally {
        if (mounted) setState(() => _isProcessingAction = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isUIBlocked = _isProcessingAction;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentScooter.marca} ${_currentScooter.modello}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: isUIBlocked ? null : _navigateToEditScooter,
          ),
        ],
      ),
      // Applichiamo SafeArea per gestire l'Edge-to-Edge
      body: SafeArea(
        top: false, // La AppBar protegge già la parte superiore
        bottom: true, // Protegge il fondo dalle gesture di sistema
        child: Stack(
          children: [
            AbsorbPointer(
              absorbing: isUIBlocked,
              child: Opacity(
                opacity: isUIBlocked ? 0.6 : 1.0,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Immagine Header
                    ScooterHeaderImage(
                      imgPath: _currentScooter.imgPath,
                      scooterId: _currentScooter.id!,
                      onTap: _openImageViewer,
                    ),
                    const SizedBox(height: 24),

                    // Card Informazioni Generali
                    ScooterInfoCard(scooter: _currentScooter),
                    const SizedBox(height: 24),

                    // Card Azioni Modulari
                    RefuelingsActionCard(scooter: _currentScooter),
                    const SizedBox(height: 12),
                    MaintenanceActionCard(scooter: _currentScooter),

                    // Spazio extra finale per una migliore respirazione visiva
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Overlay di caricamento
            if (isUIBlocked)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}