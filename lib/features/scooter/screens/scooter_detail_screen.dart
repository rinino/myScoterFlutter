// lib/features/scooter/screens/scooter_detail_screen.dart

import 'dart:io';
import 'dart:typed_data'; // Necessario per Uint8List
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// --- PACCHETTI PER CONDIVISIONE, SALVATAGGIO E PERMESSI ---
import 'package:share_plus/share_plus.dart';

import 'package:gal/gal.dart';

import 'package:myscooter/features/rifornimento/models/rifornimento.dart';
import 'package:myscooter/core/providers/core_providers.dart';

import '../model/scooter.dart';

class ScooterDetailScreen extends ConsumerStatefulWidget {
  final Scooter scooter;

  const ScooterDetailScreen({super.key, required this.scooter});

  @override
  ConsumerState<ScooterDetailScreen> createState() => _ScooterDetailScreenState();
}

class _ScooterDetailScreenState extends ConsumerState<ScooterDetailScreen> {
  List<Rifornimento> _rifornimenti = [];
  bool _isLoadingRifornimenti = true;
  bool _isProcessingAction = false;
  bool _isExportingImage = false;

  late Scooter _currentScooter;

  @override
  void initState() {
    super.initState();
    _currentScooter = widget.scooter;
    _loadRifornimenti();
  }

  // --- LOGICA DI CONDIVISIONE (Aggiornata per l'ultimissima API) ---
  Future<void> _shareImage(File imageFile) async {
    try {
      final xFile = XFile(imageFile.path);

      // Utilizziamo il nuovo metodo unificato di SharePlus
      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: 'Guarda il mio ${_currentScooter.marca} ${_currentScooter.modello}!',
          subject: 'Foto del mio Scooter',
        ),
      );
    } catch (e) {
      if (mounted) _showSnackBar('Errore durante la condivisione: $e');
    }
  }

  // --- LOGICA DI SALVATAGGIO IN GALLERIA (Sicura per gli async gap e Android 13+) ---
  // --- LOGICA DI SALVATAGGIO IN GALLERIA (Moderna con 'gal') ---
  Future<void> _saveImageToGallery(File imageFile, BuildContext viewerContext) async {
    // 1. Permessi gestiti automaticamente e intelligentemente da Gal!
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      final requestGranted = await Gal.requestAccess();
      if (!requestGranted) {
        if (mounted) _showSnackBar('Permesso negato. Abilitalo dalle impostazioni.');
        return;
      }
    }

    // --- FIX ASYNC GAP ---
    if (!viewerContext.mounted) return;

    // 2. Procediamo col salvataggio
    setState(() => _isExportingImage = true);

    showDialog(
      context: viewerContext,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      // Gal fa tutto con una singola riga di codice, senza dover convertire in bytes!
      await Gal.putImage(imageFile.path);

      if (viewerContext.mounted) Navigator.of(viewerContext).pop();
      if (mounted) _showSnackBar('Immagine salvata nella galleria!');

    } catch (e) {
      if (viewerContext.mounted) Navigator.of(viewerContext).pop();
      if (mounted) _showSnackBar('Errore imprevisto durante il salvataggio: $e');
    } finally {
      if (mounted) setState(() => _isExportingImage = false);
    }
  }

  // --- LOGICA DATI E RIFORNIMENTI ---
  Future<void> _loadRifornimenti() async {
    setState(() => _isLoadingRifornimenti = true);

    if (_currentScooter.id == null) {
      setState(() {
        _rifornimenti = [];
        _isLoadingRifornimenti = false;
      });
      return;
    }

    try {
      final repo = ref.read(rifornimentoRepoProvider);
      final rifornimenti = await repo.getRifornimentiForScooter(_currentScooter.id!);

      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _rifornimenti = rifornimenti;
        _isLoadingRifornimenti = false;
      });
    } catch (e) {
      setState(() => _isLoadingRifornimenti = false);
      if (mounted) _showSnackBar('Errore nel caricamento dei rifornimenti.');
    }
  }

  Future<void> _deleteRifornimento(int id) async {
    setState(() => _isProcessingAction = true);
    try {
      await ref.read(rifornimentoRepoProvider).deleteRifornimento(id);
      setState(() {
        _rifornimenti.removeWhere((r) => r.id == id);
      });
      if (mounted) _showSnackBar('Rifornimento eliminato.');
    } catch (e) {
      if (mounted) _showSnackBar('Errore durante l\'eliminazione.');
    } finally {
      setState(() => _isProcessingAction = false);
    }
  }

  Future<void> _navigateToEditScooter() async {
    final Scooter? updatedScooter = await context.push<Scooter?>('/add-edit-scooter', extra: _currentScooter);

    if (updatedScooter != null) {
      setState(() => _isProcessingAction = true);
      try {
        await ref.read(scooterRepoProvider).updateScooter(updatedScooter);
        setState(() => _currentScooter = updatedScooter);
        await _loadRifornimenti();
        if (mounted) _showSnackBar('Scooter aggiornato!');
      } catch (e) {
        if (mounted) _showSnackBar('Errore durante il salvataggio.');
      } finally {
        setState(() => _isProcessingAction = false);
      }
    }
  }

  Future<void> _navigateToAddRifornimento() async {
    if (_isProcessingAction) return;

    final result = await context.push('/add-edit-rifornimento/${_currentScooter.id!}');

    if (result != null) {
      await _loadRifornimenti();
      if (mounted) _showSnackBar('Rifornimento salvato!');
    }
  }

  Future<void> _navigateToRifornimentoDetail(Rifornimento rifornimento) async {
    final result = await context.push('/rifornimento-detail/${_currentScooter.id!}', extra: rifornimento);

    if (result != null) {
      await _loadRifornimenti();
    }
  }

  // --- VISUALIZZATORE IMMAGINE FULLSCREEN ---
  void _openImageViewer() {
    if (_currentScooter.imgPath == null || !File(_currentScooter.imgPath!).existsSync()) return;

    final File imageFile = File(_currentScooter.imgPath!);

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (viewerContext) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
                "${_currentScooter.marca} ${_currentScooter.modello}",
                style: const TextStyle(color: Colors.white, fontSize: 16)
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.cyanAccent),
                onPressed: () => _shareImage(imageFile),
                tooltip: 'Condividi foto',
              ),
              IconButton(
                icon: const Icon(Icons.save_alt, color: Colors.cyanAccent),
                onPressed: _isExportingImage ? null : () => _saveImageToGallery(imageFile, viewerContext),
                tooltip: 'Salva in galleria',
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              clipBehavior: Clip.none,
              child: Hero(
                tag: 'scooter_image_${_currentScooter.id}',
                child: Image.file(
                  imageFile,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bool isUIBlocked = _isProcessingAction || _isLoadingRifornimenti;
    final Color iconColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentScooter.marca} ${_currentScooter.modello}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isUIBlocked ? null : () => context.pop(true),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: isUIBlocked ? null : _navigateToEditScooter,
          ),
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
                  _buildCircularImage(),
                  const SizedBox(height: 24),
                  _buildScooterDetailsCard(iconColor),
                  const SizedBox(height: 24),
                  _buildRifornimentiSection(iconColor),
                ],
              ),
            ),
          ),
          if (isUIBlocked)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildCircularImage() {
    final bool hasImage = _currentScooter.imgPath != null && File(_currentScooter.imgPath!).existsSync();

    return Center(
      child: GestureDetector(
        onTap: hasImage && !_isProcessingAction ? _openImageViewer : null,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue.withValues(alpha: 0.5), width: 3),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: ClipOval(
            child: Hero(
              tag: 'scooter_image_${_currentScooter.id}',
              child: hasImage
                  ? Image.file(File(_currentScooter.imgPath!), fit: BoxFit.cover)
                  : Container(
                color: Colors.grey[200],
                child: const Icon(Icons.moped, size: 50, color: Colors.blue),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScooterDetailsCard(Color iconColor) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2))
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _detailRow(Icons.sell, 'Marca', _currentScooter.marca, iconColor),
            const Divider(),
            _detailRow(Icons.moped, 'Modello', _currentScooter.modello, iconColor),
            const Divider(),
            _detailRow(Icons.engineering, 'Cilindrata', '${_currentScooter.cilindrata} cc', iconColor),
            const Divider(),
            _detailRow(Icons.water_drop, 'Miscelatore', _currentScooter.miscelatore ? 'Sì' : 'No', iconColor),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRifornimentiSection(Color btnColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RIFORNIMENTI', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey)),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blue),
              onPressed: _isProcessingAction ? null : _navigateToAddRifornimento,
            )
          ],
        ),
        if (!_isLoadingRifornimenti && _rifornimenti.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Nessun dato presente'))),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rifornimenti.length,
          itemBuilder: (context, index) {
            final rif = _rifornimenti[index];
            return Dismissible(
              key: Key(rif.id.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (dir) => _showConfirmDialog(),
              onDismissed: (dir) => _deleteRifornimento(rif.id!),
              child: ListTile(
                leading: const Icon(Icons.local_gas_station),
                title: Text(DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(rif.dataRifornimento))),
                subtitle: Text('${rif.kmAttuali.toInt()} km - ${rif.mediaConsumo?.toStringAsFixed(2) ?? "N/A"} km/L'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigateToRifornimentoDetail(rif),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina'),
        content: const Text('Vuoi eliminare questo record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ANNULLA')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ELIMINA', style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}