// lib/features/scooter/screens/scooter_detail_screen.dart

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
    final Scooter? updatedScooter = await context.push<Scooter?>('/add-edit-scooter', extra: _currentScooter);

    if (updatedScooter != null) {
      setState(() => _isProcessingAction = true);
      try {
        await ref.read(scooterRepoProvider).updateScooter(updatedScooter);
        if (mounted) setState(() => _currentScooter = updatedScooter);
        ref.read(messageProvider.notifier).show(l10n.scooterUpdated, type: MessageType.success);
      } catch (e) {
        ref.read(messageProvider.notifier).show(l10n.errorUpdating, type: MessageType.error);
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
          IconButton(icon: const Icon(Icons.edit), onPressed: isUIBlocked ? null : _navigateToEditScooter),
        ],
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isUIBlocked,
            child: Opacity(
              opacity: isUIBlocked ? 0.6 : 1.0,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  ScooterHeaderImage(
                    imgPath: _currentScooter.imgPath,
                    scooterId: _currentScooter.id!,
                    onTap: _openImageViewer,
                  ),
                  const SizedBox(height: 24),
                  ScooterInfoCard(scooter: _currentScooter),
                  const SizedBox(height: 24),

                  // NUOVO BOX: DATI RIFORNIMENTI
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        context.push('/refuelings/${_currentScooter.id!}', extra: _currentScooter);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.local_gas_station,
                                size: 28,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                l10n.refuelingData, // La nuova traduzione aggiunta prima!
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
          if (isUIBlocked) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}