import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myscooter/features/manutenzione/models/manutenzione.dart';
import 'package:myscooter/core/providers/currency_provider.dart';
import 'package:myscooter/l10n/app_localizations.dart';
import 'package:myscooter/features/scooter/widgets/image_viewer_page.dart';

// FIX: Importiamo il Design System in Vetro
import 'package:myscooter/core/theme/app_colors.dart';
import '../../../core/widgets/glass_background.dart';
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
      backgroundColor: Colors.transparent, // FIX: Scaffold trasparente
      extendBodyBehindAppBar: true,        // FIX: Effetto vetro sotto l'appbar
      appBar: AppBar(
        title: Text(l10n.dettagliIntervento),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            color: AppColors.primaryMaintenance, // FIX: Icona in tema Arancione
            onPressed: _navigateToEdit,
          ),
        ],
      ),
      body: Stack(
        children: [
          // FIX: Sfondo in vetro Arancione
          const GlassBackground(
            primaryColor: AppColors.primaryMaintenance,
            secondaryColor: AppColors.secondaryMaintenance,
          ),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Nota: Per completare l'effetto, apri maintenance_info_card.dart
                // e sostituisci il widget "Card" genitore con "GlassCard"
                MaintenanceInfoCard(
                  manutenzione: _currentManutenzione,
                  currencySymbol: currencySymbol,
                ),
                const SizedBox(height: 16),

                if (_currentManutenzione.note != null && _currentManutenzione.note!.isNotEmpty) ...[
                  MaintenanceNotesCard(note: _currentManutenzione.note!),
                  const SizedBox(height: 16),
                ],

                if (_currentManutenzione.nomeFoto != null && _currentManutenzione.nomeFoto!.isNotEmpty) ...[
                  MaintenancePhotoCard(
                    manutenzione: _currentManutenzione,
                    onTap: _openImageViewer,
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