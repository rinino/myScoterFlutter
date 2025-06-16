import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myscoterflutter/models/scooter.dart';
import 'package:myscoterflutter/models/rifornimento.dart';
import 'package:myscoterflutter/repository/rifornimento_repository.dart';
import 'package:myscoterflutter/screens/add_edit_scooter_screen.dart';

class ScooterDetailScreen extends StatefulWidget {
  final Scooter scooter;

  const ScooterDetailScreen({super.key, required this.scooter});

  @override
  State<ScooterDetailScreen> createState() => _ScooterDetailScreenState();
}

class _ScooterDetailScreenState extends State<ScooterDetailScreen> {
  final RifornimentoRepository _rifornimentoRepository = RifornimentoRepository();
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

  Future<void> _loadRifornimenti() async {
    setState(() {
      _isLoadingRifornimenti = true;
    });

    if (_currentScooter.id == null) {
      print("ID dello scooter nullo, impossibile caricare i rifornimenti. Visualizzo lista vuota.");
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
      print('Errore effettivo nel caricamento dei rifornimenti: $e');
      setState(() {
        _isLoadingRifornimenti = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nel caricamento dei rifornimenti.')),
        );
      }
    }
  }

  Future<void> _navigateToEditScooter() async {
    setState(() {
      _isProcessingAction = true;
    });
    try {
      final Scooter? updatedScooter = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddEditScooterScreen(scooter: _currentScooter),
        ),
      );

      if (updatedScooter != null) {
        setState(() {
          _currentScooter = updatedScooter;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scooter modificato con successo!')),
        );
      }
    } catch (e) {
      print('Errore durante la navigazione o modifica dello scooter: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Si è verificato un errore durante la modifica.')),
        );
      }
    } finally {
      setState(() {
        _isProcessingAction = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scooter = _currentScooter;

    final Color appBarTitleColor = Theme.of(context).colorScheme.onPrimaryContainer;
    final Color detailTextColor = Colors.white70;

    return Scaffold(
      appBar: AppBar(
        title: Text('${scooter.marca} ${scooter.modello}'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
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
                              'Dettagli Scooter',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: appBarTitleColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('Marca: ${scooter.marca}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: detailTextColor)),
                            Text('Modello: ${scooter.modello}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: detailTextColor)),
                            Text('Cilindrata: ${scooter.cilindrata}cc', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: detailTextColor)),
                            Text('Targa: ${scooter.targa}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: detailTextColor)),
                            // --- AGGIUNTA PER MOSTRARE L'ID DELLO SCOOTER ---
                            Text('ID: ${scooter.id ?? 'N/A'}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: detailTextColor)),
                            // --- FINE AGGIUNTA ---
                            Text('Anno: ${scooter.anno}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: detailTextColor)),
                            Text('Miscelatore: ${scooter.miscelatore ? 'Sì' : 'No'}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: detailTextColor)),

                            const SizedBox(height: 16),

                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade700),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: (scooter.imgPath != null && File(scooter.imgPath!).existsSync())
                                    ? Image.file(
                                  File(scooter.imgPath!),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(Icons.broken_image, color: Colors.grey, size: 60),
                                      ),
                                    );
                                  },
                                )
                                    : Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.no_photography, color: Colors.grey, size: 60),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 28,
                          ),
                          onPressed: _isProcessingAction ? null : _navigateToEditScooter,
                          tooltip: 'Modifica scooter',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

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
                          'Rifornimenti',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: appBarTitleColor,
                          ),
                        ),
                        const SizedBox(height: 10),

                        _isLoadingRifornimenti
                            ? const Center(child: CircularProgressIndicator())
                            : _rifornimenti.isEmpty
                            ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              'Nessun rifornimento presente.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic, color: detailTextColor),
                            ),
                          ),
                        )
                            : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _rifornimenti.length,
                          itemBuilder: (context, index) {
                            final rifornimento = _rifornimenti[index];
                            return Card(
                              color: Colors.grey[700],
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              elevation: 2.0,
                              child: ListTile(
                                leading: const Icon(Icons.local_gas_station, color: Colors.white70),
                                title: Text(
                                  'Data: ${rifornimento.formattedDataRifornimento} - Km: ${rifornimento.kmAttuali.toStringAsFixed(0)}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Benzina: ${rifornimento.litriBenzina.toStringAsFixed(2)} L'
                                      ' ${rifornimento.litriOlio != null ? ' - Olio: ${rifornimento.litriOlio!.toStringAsFixed(2)} L' : ''}'
                                      ' - Consumo: ${rifornimento.mediaConsumo != null ? rifornimento.mediaConsumo!.toStringAsFixed(2) : 'N/A'} km/L',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                onTap: () {
                                  print('Rifornimento tapped: ${rifornimento.id}');
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isProcessingAction)
            ModalBarrier(
              color: Colors.black.withOpacity(0.5),
              dismissible: false,
            ),
          if (_isProcessingAction)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}