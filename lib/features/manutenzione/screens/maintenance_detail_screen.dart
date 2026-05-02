import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:myscooter/features/manutenzione/models/manutenzione.dart';
import 'package:myscooter/core/providers/currency_provider.dart';
import 'package:myscooter/l10n/app_localizations.dart';
import 'package:myscooter/features/scooter/widgets/image_viewer_page.dart';

// Importiamo i nuovi widget estratti
import '../widgets/maintenance_info_card.dart';
import '../widgets/maintenance_notes_card.dart';
import '../widgets/maintenance_photo_card.dart';

class MaintenanceDetailScreen extends ConsumerStatefulWidget {
  final Manutenzione manutenzione;

  const MaintenanceDetailScreen({super.key, required this.manutenzione});

  @override
  ConsumerState<MaintenanceDetailScreen> createState() => _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState extends ConsumerState<MaintenanceDetailScreen> {
  late Manutenzione _currentManutenzione;

  @override
  void initState() {
    super.initState();
    _currentManutenzione = widget.manutenzione;
  }

  void _openImageViewer() {
    if (_currentManutenzione.nomeFoto == null || !File(_currentManutenzione.nomeFoto!).existsSync()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ImageViewerPage(
          imageFile: File(_currentManutenzione.nomeFoto!),
          title: _currentManutenzione.titolo,
          heroTag: 'maint_image_${_currentManutenzione.id}',
        ),
      ),
    );
  }

  Future<void> _navigateToEdit() async {
    await context.push('/add-edit-maintenance', extra: {
      'scooterId': _currentManutenzione.scooterId, // FIX: scooterId al posto di idScooter
      'manutenzione': _currentManutenzione,
    });
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dettagliIntervento),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEdit,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          MaintenanceInfoCard(
            manutenzione: _currentManutenzione,
            currencySymbol: currencySymbol,
          ),
          const SizedBox(height: 16),

          if (_currentManutenzione.note != null && _currentManutenzione.note!.isNotEmpty) ...[
            MaintenanceNotesCard(note: _currentManutenzione.note!),
            const SizedBox(height: 16),
          ],

          if (_currentManutenzione.nomeFoto != null && File(_currentManutenzione.nomeFoto!).existsSync()) ...[
            MaintenancePhotoCard(
              manutenzione: _currentManutenzione,
              onTap: _openImageViewer,
            ),
          ],
        ],
      ),
    );
  }
}