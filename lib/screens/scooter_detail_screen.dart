import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myscoterflutter/models/scooter.dart';
import 'package:myscoterflutter/models/rifornimento.dart';
import 'package:myscoterflutter/repository/rifornimento_repository.dart';

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

  @override
  void initState() {
    super.initState();
    _loadRifornimenti();
  }

  Future<void> _loadRifornimenti() async {
    setState(() {
      _isLoadingRifornimenti = true;
    });
    try {
      if (widget.scooter.id == null) {
        throw Exception("ID dello scooter nullo, impossibile caricare i rifornimenti.");
      }
      final rifornimenti = await _rifornimentoRepository.getRifornimentiForScooter(widget.scooter.id!);
      setState(() {
        _rifornimenti = rifornimenti;
        _isLoadingRifornimenti = false;
      });
    } catch (e) {
      print('Errore nel caricamento dei rifornimenti: $e');
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

  @override
  Widget build(BuildContext context) {
    final scooter = widget.scooter;

    return Scaffold(
      appBar: AppBar(
        title: Text('${scooter.marca} ${scooter.modello}'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contenitore UNIFICATO per i dettagli dello scooter e l'immagine
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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Marca: ${scooter.marca}', style: Theme.of(context).textTheme.bodyLarge),
                    Text('Modello: ${scooter.modello}', style: Theme.of(context).textTheme.bodyLarge),
                    Text('Cilindrata: ${scooter.cilindrata}cc', style: Theme.of(context).textTheme.bodyLarge),
                    Text('Targa: ${scooter.targa}', style: Theme.of(context).textTheme.bodyLarge),
                    Text('Anno: ${scooter.anno}', style: Theme.of(context).textTheme.bodyLarge),
                    Text('Miscelatore: ${scooter.miscelatore ? 'Sì' : 'No'}', style: Theme.of(context).textTheme.bodyLarge),

                    const SizedBox(height: 16), // Spazio tra i dettagli testuali e l'immagine

                    // Sezione Immagine all'interno del box unificato
                    Text(
                      'Immagine Scooter',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade700),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: (scooter.imgPath != null && scooter.imgPath!.isNotEmpty)
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
              const SizedBox(height: 16), // Spazio tra il box unificato e i rifornimenti

              // Contenitore per la lista dei rifornimenti (rimane separato)
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
                        color: Theme.of(context).colorScheme.onSurface,
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
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
    );
  }
}