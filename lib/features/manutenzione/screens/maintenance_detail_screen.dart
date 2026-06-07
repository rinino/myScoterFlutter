import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // FIX PRO
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myscooter/features/manutenzione/models/manutenzione.dart';
import 'package:myscooter/core/providers/currency_provider.dart';
import 'package:myscooter/l10n/app_localizations.dart';
import 'package:myscooter/features/scooter/widgets/image_viewer_page.dart';

import 'package:myscooter/core/theme/app_colors.dart';
import '../../../core/widgets/glass_background.dart';
import '../../../core/widgets/custom_glass_card.dart'; // FIX PRO
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
    if (_currentManutenzione.nomeFoto == null || _currentManutenzione.nomeFoto!.isEmpty) return;
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ImageViewerPage(
          imagePath: _currentManutenzione.nomeFoto!,
          title: _currentManutenzione.titolo,
          heroTag: 'maint_image_${_currentManutenzione.id}',
        ),
      ),
    );
  }

  Future<void> _navigateToEdit() async {
    HapticFeedback.lightImpact();
    final result = await context.push('/add-edit-maintenance/${_currentManutenzione.scooterId}', extra: _currentManutenzione);
    if (result != null && result is Manutenzione) {
      setState(() {
        _currentManutenzione = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.dettagliIntervento),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            color: Colors.orange, // FIX PRO: Tema Arancione
            onPressed: _navigateToEdit,
          ),
        ],
      ),
      body: Stack(
        children: [
          const GlassBackground(
            primaryColor: Colors.orange,
            secondaryColor: Colors.yellow,
          ),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // CARD 1: Dettagli
                CustomGlassCard(
                  borderColors: [
                    Colors.orange.withOpacity(0.4),
                    Colors.yellow.withOpacity(0.15),
                    Colors.transparent,
                  ],
                  // ASSICURATI DI RIMUOVERE "Card()" DA DENTRO MaintenanceInfoCard!
                  child: MaintenanceInfoCard(
                    manutenzione: _currentManutenzione,
                    currencySymbol: currencySymbol,
                  ),
                ),
                const SizedBox(height: 16),

                // CARD 2: Note
                if (_currentManutenzione.note != null && _currentManutenzione.note!.isNotEmpty) ...[
                  CustomGlassCard(
                    borderColors: [
                      Colors.orange.withOpacity(0.4),
                      Colors.yellow.withOpacity(0.15),
                      Colors.transparent,
                    ],
                    // ASSICURATI DI RIMUOVERE "Card()" DA DENTRO MaintenanceNotesCard!
                    child: MaintenanceNotesCard(note: _currentManutenzione.note!),
                  ),
                  const SizedBox(height: 16),
                ],

                // CARD 3: Foto
                if (_currentManutenzione.nomeFoto != null && _currentManutenzione.nomeFoto!.isNotEmpty) ...[
                  CustomGlassCard(
                    borderColors: [
                      Colors.orange.withOpacity(0.4),
                      Colors.yellow.withOpacity(0.15),
                      Colors.transparent,
                    ],
                    // ASSICURATI DI RIMUOVERE "Card()" DA DENTRO MaintenancePhotoCard!
                    child: MaintenancePhotoCard(
                      manutenzione: _currentManutenzione,
                      onTap: _openImageViewer,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}