import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myscooter/models/scooter.dart';
import 'package:myscooter/models/rifornimento.dart';
import 'package:myscooter/repository/rifornimento_repository.dart';
import 'package:myscooter/repository/scooter_repository.dart'; // ASSICURATI CHE ESISTA
import 'package:myscooter/screens/add_edit_scooter_screen.dart';
import 'package:myscooter/screens/add_edit_rifornimento_screen.dart';
import 'package:myscooter/screens/rifornimento_detail_screen.dart';
import 'package:intl/intl.dart';

class ScooterDetailScreen extends StatefulWidget {
  final Scooter scooter;

  const ScooterDetailScreen({super.key, required this.scooter});

  @override
  State<ScooterDetailScreen> createState() => _ScooterDetailScreenState();
}

class _ScooterDetailScreenState extends State<ScooterDetailScreen> {
  final RifornimentoRepository _rifornimentoRepository = RifornimentoRepository();
  final ScooterRepository _scooterRepository = ScooterRepository(); // Repository per salvare modifiche scooter

  List<Rifornimento> _rifornimenti = [];
  bool _isLoadingRifornimenti = true;
  bool _isProcessingAction = false;

  late Scooter _currentScooter;

  @override
  void initState() {
    super.initState();
    _currentScooter = widget.scooter;
    _loadRifornimenti();
  }

  // Caricamento lista rifornimenti
  Future<void> _loadRifornimenti() async {
    setState(() {
      _isLoadingRifornimenti = true;
    });

    if (_currentScooter.id == null) {
      setState(() {
        _rifornimenti = [];
        _isLoadingRifornimenti = false;
      });
      return;
    }

    try {
      final rifornimenti = await _rifornimentoRepository.getRifornimentiForScooter(_currentScooter.id!);
      setState(() {
        _rifornimenti = rifornimenti;
        _isLoadingRifornimenti = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRifornimenti = false;
      });
      if (mounted) {
        _showSnackBar('Errore nel caricamento dei rifornimenti.');
      }
    }
  }

  // Eliminazione di un singolo rifornimento (Swipe)
  Future<void> _deleteRifornimento(int id) async {
    setState(() => _isProcessingAction = true);
    try {
      await _rifornimentoRepository.deleteRifornimento(id);
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

  // Modifica dello Scooter (Risolve l'anomalia dell'aggiornamento)
  Future<void> _navigateToEditScooter() async {
    final Scooter? updatedScooter = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditScooterScreen(scooter: _currentScooter),
      ),
    );

    if (updatedScooter != null) {
      setState(() => _isProcessingAction = true);
      try {
        // SALVATAGGIO SU DATABASE
        await _scooterRepository.updateScooter(updatedScooter);

        // AGGIORNAMENTO UI
        setState(() {
          _currentScooter = updatedScooter;
        });

        if (mounted) _showSnackBar('Scooter aggiornato con successo!');
      } catch (e) {
        if (mounted) _showSnackBar('Errore durante il salvataggio su DB.');
      } finally {
        setState(() => _isProcessingAction = false);
      }
    }
  }

  Future<void> _navigateToAddRifornimento() async {
    if (_isProcessingAction) return;
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditRifornimentoScreen(scooterId: _currentScooter.id!),
      ),
    );

    if (result == true) {
      await _loadRifornimenti();
      if (mounted) _showSnackBar('Rifornimento salvato!');
    }
  }

  Future<void> _navigateToRifornimentoDetail(Rifornimento rifornimento) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RifornimentoDetailScreen(
          rifornimento: rifornimento,
          scooterId: _currentScooter.id!,
        ),
      ),
    );

    if (result == true) {
      await _loadRifornimenti();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarTitleColor = Theme.of(context).colorScheme.onPrimaryContainer;
    final Color detailTextColor = Colors.white70;
    final Color addButtonColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentScooter.marca} ${_currentScooter.modello}'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        // IMPORTANTE: Quando torniamo alla lista principale, dobbiamo dire se è cambiato qualcosa
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD DETTAGLI SCOOTER
                  _buildScooterHeader(context, appBarTitleColor, detailTextColor),
                  const SizedBox(height: 16),
                  // SEZIONE RIFORNIMENTI
                  _buildRifornimentiSection(context, appBarTitleColor, detailTextColor, addButtonColor),
                ],
              ),
            ),
          ),
          if (_isProcessingAction) ...[
            const ModalBarrier(color: Colors.black54, dismissible: false),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  Widget _buildScooterHeader(BuildContext context, Color titleColor, Color textColor) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(8.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dettagli Scooter', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: titleColor)),
              const SizedBox(height: 10),
              _detailText('Marca: ${_currentScooter.marca}', textColor),
              _detailText('Modello: ${_currentScooter.modello}', textColor),
              _detailText('Cilindrata: ${_currentScooter.cilindrata}cc', textColor),
              _detailText('Targa: ${_currentScooter.targa}', textColor),
              _detailText('Anno: ${_currentScooter.anno}', textColor),
              _detailText('Miscelatore: ${_currentScooter.miscelatore ? 'Sì' : 'No'}', textColor),
              const SizedBox(height: 16),
              _buildImageHolder(),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary, size: 28),
            onPressed: _isProcessingAction ? null : _navigateToEditScooter,
          ),
        ),
      ],
    );
  }

  Widget _buildRifornimentiSection(BuildContext context, Color titleColor, Color textColor, Color btnColor) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(8.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rifornimenti', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: titleColor)),
          const SizedBox(height: 10),
          _isLoadingRifornimenti
              ? const Center(child: CircularProgressIndicator())
              : _rifornimenti.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Nessun rifornimento.', style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic))))
              : ListView.builder(
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (dir) => _showConfirmDialog(),
                onDismissed: (dir) => _deleteRifornimento(rif.id!),
                child: Card(
                  color: Colors.grey[700],
                  child: ListTile(
                    leading: const Icon(Icons.local_gas_station, color: Colors.white70),
                    title: Text('Data: ${DateFormat('dd/MM/yyyy').format(rif.dateTime)} - Km: ${rif.kmAttuali.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white)),
                    subtitle: Text('${rif.litriBenzina.toStringAsFixed(2)} L - ${rif.mediaConsumo?.toStringAsFixed(2) ?? "N/A"} km/L', style: const TextStyle(color: Colors.white70)),
                    onTap: () => _navigateToRifornimentoDetail(rif),
                  ),
                ),
              );
            },
          ),
          Center(
            child: TextButton.icon(
              onPressed: _isProcessingAction ? null : _navigateToAddRifornimento,
              icon: Icon(Icons.add_circle_outline, color: btnColor),
              label: Text('Aggiungi rifornimento', style: TextStyle(color: btnColor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailText(String text, Color color) => Text(text, style: TextStyle(color: color, fontSize: 16));

  Widget _buildImageHolder() {
    return Container(
      height: 150, width: double.infinity,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade700), borderRadius: BorderRadius.circular(8.0)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: (_currentScooter.imgPath != null && File(_currentScooter.imgPath!).existsSync())
            ? Image.file(File(_currentScooter.imgPath!), fit: BoxFit.cover)
            : Container(color: Colors.grey[200], child: const Icon(Icons.no_photography, color: Colors.grey, size: 60)),
      ),
    );
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Conferma'),
        content: const Text('Eliminare questo rifornimento?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ANNULLA')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ELIMINA', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}