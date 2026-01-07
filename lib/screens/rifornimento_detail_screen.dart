import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myscooter/models/rifornimento.dart';
import 'package:myscooter/screens/add_edit_rifornimento_screen.dart';
import 'package:myscooter/repository/rifornimento_repository.dart'; // IMPORTANTE: Aggiunto repository

class RifornimentoDetailScreen extends StatefulWidget {
  final Rifornimento rifornimento;
  final int scooterId;

  const RifornimentoDetailScreen({
    super.key,
    required this.rifornimento,
    required this.scooterId,
  });

  @override
  State<RifornimentoDetailScreen> createState() => _RifornimentoDetailScreenState();
}

class _RifornimentoDetailScreenState extends State<RifornimentoDetailScreen> {
  late Rifornimento _currentRifornimento;
  final RifornimentoRepository _rifornimentoRepository = RifornimentoRepository(); // Istanza repository
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _currentRifornimento = widget.rifornimento;
  }

  // NUOVO: Funzione per eliminare il rifornimento con conferma
  Future<void> _confirmAndDeleteRifornimento() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Rifornimento'),
        content: const Text('Sei sicuro di voler eliminare questo record? l\'azione è irreversibile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ANNULLA'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ELIMINA'),
          ),
        ],
      ),
    );

    if (confirm == true && _currentRifornimento.id != null) {
      setState(() => _isDeleting = true);
      try {
        await _rifornimentoRepository.deleteRifornimento(_currentRifornimento.id!);
        if (mounted) {
          // Torniamo indietro indicando che un elemento è stato rimosso
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rifornimento eliminato con successo.')),
          );
        }
      } catch (e) {
        setState(() => _isDeleting = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Errore durante l\'eliminazione.')),
          );
        }
      }
    }
  }

  void _showMediaConsumoInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Calcolo Consumo Medio'),
          content: const Text(
            'Il consumo medio viene calcolato dividendo i chilometri percorsi dall\'ultimo rifornimento per i litri di benzina inseriti in questo rifornimento. Si assume che ad ogni rifornimento venga fatto il pieno.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToEditRifornimento() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditRifornimentoScreen(
          scooterId: widget.scooterId,
          rifornimento: _currentRifornimento,
        ),
      ),
    );

    if (result == true) {
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarTitleColor = Theme.of(context).colorScheme.onPrimaryContainer;
    final Color detailTextColor = Colors.white70;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio Rifornimento'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          // NUOVO: Tasto elimina nella AppBar
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _isDeleting ? null : _confirmAndDeleteRifornimento,
            tooltip: 'Elimina rifornimento',
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.secondary,
              size: 28,
            ),
            onPressed: _isDeleting ? null : _navigateToEditRifornimento,
            tooltip: 'Modifica rifornimento',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dettagli Rifornimento',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: appBarTitleColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildDetailRow('Data', DateFormat('dd/MM/yyyy HH:mm').format(_currentRifornimento.dateTime), detailTextColor),
                      _buildDetailRow('Km Attuali', '${_currentRifornimento.kmAttuali.toStringAsFixed(0)} km', detailTextColor),
                      _buildDetailRow('Litri Benzina', '${_currentRifornimento.litriBenzina.toStringAsFixed(2)} L', detailTextColor),
                      if (_currentRifornimento.litriOlio != null)
                        _buildDetailRow('Litri Olio', '${_currentRifornimento.litriOlio!.toStringAsFixed(2)} L', detailTextColor),
                      if (_currentRifornimento.percentualeOlio != null)
                        _buildDetailRow('Percentuale Olio', '${_currentRifornimento.percentualeOlio!.toStringAsFixed(2)}%', detailTextColor),
                      _buildDetailRow('Km Percorsi', '${_currentRifornimento.kmPercorsi.toStringAsFixed(2)} km', detailTextColor),
                      Row(
                        children: [
                          Text(
                            'Media Consumo: ${_currentRifornimento.mediaConsumo != null ? _currentRifornimento.mediaConsumo!.toStringAsFixed(2) : 'N/A'} km/L',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: detailTextColor),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
                            onPressed: () => _showMediaConsumoInfo(context),
                            tooltip: 'Informazioni sul calcolo del consumo medio',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isDeleting)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  // Piccolo helper per pulire il codice della UI
  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color),
      ),
    );
  }
}