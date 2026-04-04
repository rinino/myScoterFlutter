// lib/features/rifornimento/screens/rifornimento_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myscooter/features/rifornimento/models/rifornimento.dart';
import '../../../l10n/app_localizations.dart';

class RifornimentoDetailScreen extends ConsumerWidget { // Trasformato in ConsumerWidget
  final int scooterId;
  final Rifornimento rifornimento;

  const RifornimentoDetailScreen({
    super.key,
    required this.scooterId,
    required this.rifornimento
  });

  Future<void> _launchMapUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showMapOptions(BuildContext context, double lat, double lon, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.posizioneGPSLabel,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.map, color: Colors.blue),
                title: Text(l10n.apriInGoogleMaps),
                onTap: () {
                  Navigator.pop(ctx);
                  //final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
                  final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
                  _launchMapUrl(url);
                },
              ),
              ListTile(
                leading: const Icon(Icons.navigation, color: Colors.lightBlue),
                title: Text(l10n.apriInWaze),
                onTap: () {
                  Navigator.pop(ctx);
                  final url = 'https://waze.com/ul?ll=$lat,$lon&navigate=yes';
                  _launchMapUrl(url);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Aggiunto WidgetRef
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(rifornimento.formattedDataRifornimento),
        centerTitle: true,
        // --- IL TASTO MODIFICA È TORNATO QUI! ---
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              context.pushNamed(
                'add-edit-rifornimento',
                pathParameters: {'scooterId': scooterId.toString()},
                extra: rifornimento,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CARD DATI PRINCIPALI
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.calendar_today, l10n.date, rifornimento.formattedDataRifornimento),
                      const Divider(),
                      _buildDetailRow(Icons.speed, l10n.currentKm, "${rifornimento.kmAttuali.toStringAsFixed(1)} km"),
                      const Divider(),
                      _buildDetailRow(Icons.local_gas_station, l10n.gasLiters, "${rifornimento.litriBenzina.toStringAsFixed(2)} L"),

                      if (rifornimento.litriOlio != null) ...[
                        const Divider(),
                        _buildDetailRow(Icons.oil_barrel, l10n.oilLiters, "${rifornimento.litriOlio!.toStringAsFixed(2)} L"),
                      ],

                      if (rifornimento.costo != null) ...[
                        const Divider(),
                        _buildDetailRow(Icons.payments_outlined, l10n.costoLabel, "€ ${rifornimento.costo!.toStringAsFixed(2)}"),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // STATISTICHE
              Card(
                elevation: 2,
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.route, l10n.kmTraveled, "${rifornimento.kmPercorsi.toStringAsFixed(1)} km"),
                      const Divider(),
                      _buildDetailRow(Icons.analytics, l10n.averageConsumption,
                          rifornimento.mediaConsumo != null ? "${rifornimento.mediaConsumo!.toStringAsFixed(2)} km/L" : "-"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // NOTE
              if (rifornimento.note != null && rifornimento.note!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(l10n.noteLabel.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      rifornimento.note!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // MAPPA
              if (rifornimento.latitudine != null && rifornimento.longitudine != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(l10n.posizioneGPSLabel.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: GestureDetector(
                    onTap: () => _showMapOptions(context, rifornimento.latitudine!, rifornimento.longitudine!, l10n),
                    child: AbsorbPointer(
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(rifornimento.latitudine!, rifornimento.longitudine!),
                            zoom: 15.0,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('distributore_pin'),
                              position: LatLng(rifornimento.latitudine!, rifornimento.longitudine!),
                            )
                          },
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          mapToolbarEnabled: false,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 24),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}