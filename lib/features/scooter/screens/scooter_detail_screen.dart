import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:myscooter/core/providers/message_provider.dart';
import 'package:myscooter/core/providers/core_providers.dart';
import 'package:myscooter/core/providers/currency_provider.dart';
import 'package:myscooter/core/services/pdf_service.dart';

// IMPORT AGGIUNTIVI PER LE NOTIFICHE
import 'package:myscooter/core/notifications/notification_service.dart';
import 'package:myscooter/features/documenti/providers/documento_provider.dart';
import 'package:myscooter/features/documenti/models/documento.dart';

// FIX: Importiamo i widget del Design System
import 'package:myscooter/core/theme/app_colors.dart';

// IMPORT WIDGETS
import '../../../core/widgets/glass_background.dart';
import '../widgets/scooter_header_image.dart';
import '../widgets/scooter_info_card.dart';
import '../widgets/image_viewer_page.dart';
import '../widgets/refuelings_action_card.dart';
import '../widgets/maintenance_action_card.dart';
import '../../documenti/widgets/documenti_carousel_view.dart';

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
  bool _isGeneratingPDF = false;
  bool _hasCheckedScadenze = false; // Flag per evitare spam di notifiche continue
  late Scooter _currentScooter;

  @override
  void initState() {
    super.initState();
    _currentScooter = widget.scooter;
  }

  void _openImageViewer() {
    if (_currentScooter.imgName == null || _currentScooter.imgName!.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ImageViewerPage(
          imagePath: _currentScooter.imgName!,
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

  Future<void> _generaPDF() async {
    setState(() => _isGeneratingPDF = true);
    try {
      final l10n = AppLocalizations.of(context)!;
      final localeCode = Localizations.localeOf(context).languageCode;
      final currency = ref.read(currencyProvider);

      final rifornimenti = await ref.read(rifornimentoRepoProvider).getRifornimentiForScooter(_currentScooter.id!);
      final manutenzioni = await ref.read(manutenzioneRepoProvider).getManutenzioni(_currentScooter.id!);

      await PdfService.generateAndShareReport(
        scooter: _currentScooter,
        rifornimenti: rifornimenti,
        manutenzioni: manutenzioni,
        currencySymbol: currency,
        l10n: l10n,
        localeCode: localeCode,
      );
    } catch (e) {
      if (mounted) ref.read(messageProvider.notifier).show(e.toString(), type: MessageType.error);
    } finally {
      if (mounted) setState(() => _isGeneratingPDF = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isUIBlocked = _isProcessingAction;

    // --- LOGICA DI CONTROLLO SCADENZE IN TEMPO REALE ---
    ref.listen<AsyncValue<List<Documento>>>(documentiStreamProvider(_currentScooter.id!), (previous, next) {
      next.whenData((documenti) {
        if (!_hasCheckedScadenze) {
          _hasCheckedScadenze = true;

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          final scaduti = documenti.where((d) {
            if (d.dataScadenza == null) return false;
            final exp = DateTime(d.dataScadenza!.year, d.dataScadenza!.month, d.dataScadenza!.day);
            return exp.isBefore(today) || exp.isAtSameMomentAs(today);
          }).toList();

          if (scaduti.isNotEmpty) {
            NotificationService().showInstantNotificationForExpiredDocs(scaduti, l10n);
            NotificationService().scheduleFutureReminders(scaduti, l10n);
          } else {
            NotificationService().cancelAllReminders();
          }
        }
      });
    });
    // ----------------------------------------------------

    return Scaffold(
      backgroundColor: Colors.transparent, // FIX: Sfondo trasparente
      extendBodyBehindAppBar: true,        // FIX: La UI scorre sotto la barra in alto
      appBar: AppBar(
        title: Text(
          '${_currentScooter.marca} ${_currentScooter.modello}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, // FIX: AppBar invisibile per mostrare il vetro
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            color: AppColors.primaryBlue, // FIX: Icona in tema
            onPressed: isUIBlocked ? null : _navigateToEditScooter,
          ),
        ],
      ),
      body: Stack(
        children: [
          // FIX: Aggiunto lo sfondo in vetro
          const GlassBackground(
            primaryColor: AppColors.primaryBlue,
            secondaryColor: AppColors.secondaryCyan,
          ),

          SafeArea(
            bottom: false, // Lasciamo che il bottone PDF arrivi fino in fondo
            child: Stack(
              children: [
                AbsorbPointer(
                  absorbing: isUIBlocked,
                  child: Opacity(
                    opacity: isUIBlocked ? 0.6 : 1.0,
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        ScooterHeaderImage(
                          imgPath: _currentScooter.imgName,
                          scooterId: _currentScooter.id!,
                          onTap: _openImageViewer,
                        ),
                        const SizedBox(height: 24),
                        ScooterInfoCard(scooter: _currentScooter),
                        DocumentiCarouselView(scooterId: _currentScooter.id!),
                        const SizedBox(height: 16),
                        RefuelingsActionCard(scooter: _currentScooter),
                        const SizedBox(height: 12),
                        MaintenanceActionCard(scooter: _currentScooter),
                        const SizedBox(height: 100), // Spazio extra per non coprire l'ultimo elemento col bottone
                      ],
                    ),
                  ),
                ),

                // Bottone PDF moderno e fluttuante
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
                    child: ElevatedButton.icon(
                      onPressed: _isGeneratingPDF || isUIBlocked ? null : _generaPDF,
                      icon: _isGeneratingPDF
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.picture_as_pdf, color: Colors.white),
                      label: Text(
                        l10n.esportaPDF,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Bordi più arrotondati
                        elevation: 8,
                        shadowColor: AppColors.primaryBlue.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                if (isUIBlocked)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}