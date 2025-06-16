import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myscoterflutter/models/rifornimento.dart';
import 'package:myscoterflutter/screens/add_edit_rifornimento_screen.dart'; // Per la navigazione alla modifica

class RifornimentoDetailScreen extends StatefulWidget {
  final Rifornimento rifornimento;
  final int scooterId; // Necessario per la modifica del rifornimento

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

  @override
  void initState() {
    super.initState();
    _currentRifornimento = widget.rifornimento;
  }

  // Funzione per mostrare l'alert sulla media consumo
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
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Funzione per navigare alla schermata di modifica
  Future<void> _navigateToEditRifornimento() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditRifornimentoScreen(
          scooterId: widget.scooterId,
          rifornimento: _currentRifornimento, // Passa il rifornimento corrente
        ),
      ),
    );

    if (result == true) {
      // Se il rifornimento è stato modificato, ricarica i dati o aggiorna lo stato
      // In questo caso, visto che AddEditRifornimentoScreen restituisce true,
      // dobbiamo tornare indietro dalla RifornimentoDetailScreen alla ScooterDetailScreen
      // per far sì che ScooterDetailScreen ricarichi la sua lista.
      // Oppure, più elegante, la AddEditRifornimentoScreen potrebbe restituire
      // il Rifornimento aggiornato, e noi lo useremmo per aggiornare _currentRifornimento.
      // Per semplicità, per ora facciamo un pop e affidiamoci a ScooterDetailScreen.
      if (mounted) {
        Navigator.pop(context, true); // Indica a ScooterDetailScreen che c'è stato un aggiornamento
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
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.secondary,
              size: 28,
            ),
            onPressed: _navigateToEditRifornimento,
            tooltip: 'Modifica rifornimento',
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                  Text(
                    'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(_currentRifornimento.dateTime)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: detailTextColor),
                  ),
                  Text(
                    'Km Attuali: ${_currentRifornimento.kmAttuali.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: detailTextColor),
                  ),
                  Text(
                    'Litri Benzina: ${_currentRifornimento.litriBenzina.toStringAsFixed(2)} L',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: detailTextColor),
                  ),
                  if (_currentRifornimento.litriOlio != null)
                    Text(
                      'Litri Olio: ${_currentRifornimento.litriOlio!.toStringAsFixed(2)} L',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: detailTextColor),
                    ),
                  if (_currentRifornimento.percentualeOlio != null)
                    Text(
                      'Percentuale Olio: ${_currentRifornimento.percentualeOlio!.toStringAsFixed(2)}%',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: detailTextColor),
                    ),
                  Text(
                    'Km Percorsi: ${_currentRifornimento.kmPercorsi.toStringAsFixed(2)} km',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: detailTextColor),
                  ),
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
    );
  }
}