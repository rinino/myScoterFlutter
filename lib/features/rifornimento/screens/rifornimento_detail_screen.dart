import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myscooter/features/rifornimento/models/rifornimento.dart';
import '../../../l10n/app_localizations.dart';

// FIX: Importiamo il Design System
import 'package:myscooter/core/theme/app_colors.dart';
import 'package:myscooter/core/widgets/glass_background.dart';
import 'package:myscooter/core/widgets/glass_card.dart';

class RifornimentoDetailScreen extends ConsumerStatefulWidget {
  final String scooterId;
  final Rifornimento rifornimento;

  const RifornimentoDetailScreen({
    super.key,
    required this.scooterId,
    required this.rifornimento
  });

  @override
  ConsumerState<RifornimentoDetailScreen> createState() => _RifornimentoDetailScreenState();
}

class _RifornimentoDetailScreenState extends ConsumerState<RifornimentoDetailScreen> {
  late Rifornimento _currentRif;

  @override
  void initState() {
    super.initState();
    _currentRif = widget.rifornimento;
  }

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
                leading: const Icon(Icons.map, color: AppColors.primaryBlue),
                title: Text(l10n.apriInGoogleMaps),
                onTap: () {
                  Navigator.pop(ctx);
                  final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
                  _launchMapUrl(url);
                },
              ),
              ListTile(
                leading: const Icon(Icons.navigation, color: AppColors.secondaryCyan),
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent, // FIX: Scaffold trasparente
      extendBodyBehindAppBar: true,        // FIX: Glass effect
      appBar: AppBar(
        title: Text(_currentRif.formattedDataRifornimento),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.primaryBlue, // FIX: Colore a tema
            onPressed: () async {
              final result = await context.pushNamed(
                'add-edit-rifornimento',
                pathParameters: {'scooterId': widget.scooterId},
                extra: _currentRif,
              );
              if (result != null && result is Rifornimento) {
                setState(() {
                  _currentRif = result;
                });
              }
            },
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.calendar_today, l10n.date, _currentRif.formattedDataRifornimento),
                          const Divider(),
                          _buildDetailRow(Icons.speed, l10n.currentKm, "${_currentRif.kmAttuali.toStringAsFixed(1)} km"),
                          const Divider(),
                          _buildDetailRow(Icons.local_gas_station, l10n.gasLiters, "${_currentRif.litriBenzina.toStringAsFixed(2)} L"),
                          if (_currentRif.litriOlio != null) ...[
                            const Divider(),
                            _buildDetailRow(Icons.oil_barrel, l10n.oilLiters, "${_currentRif.litriOlio!.toStringAsFixed(2)} L"),
                          ],
                          if (_currentRif.costo != null) ...[
                            const Divider(),
                            _buildDetailRow(Icons.payments_outlined, l10n.costoLabel, "€ ${_currentRif.costo!.toStringAsFixed(2)}"),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    GlassCard(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.route, l10n.kmTraveled, "${_currentRif.kmPercorsi.toStringAsFixed(1)} km"),
                          const Divider(),
                          _buildDetailRow(Icons.analytics, l10n.averageConsumption,
                              _currentRif.mediaConsumo != null ? "${_currentRif.mediaConsumo!.toStringAsFixed(2)} km/L" : "-"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_currentRif.note != null && _currentRif.note!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(l10n.noteLabel.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      GlassCard(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            _currentRif.note!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_currentRif.latitudine != null && _currentRif.longitudine != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(l10n.posizioneGPSLabel.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      GlassCard(
                        padding: EdgeInsets.zero,
                        child: GestureDetector(
                          onTap: () => _showMapOptions(context, _currentRif.latitudine!, _currentRif.longitudine!, l10n),
                          child: AbsorbPointer(
                            child: SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(_currentRif.latitudine!, _currentRif.longitudine!),
                                    zoom: 15.0,
                                  ),
                                  markers: {
                                    Marker(
                                      markerId: const MarkerId('distributore_pin'),
                                      position: LatLng(_currentRif.latitudine!, _currentRif.longitudine!),
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
                      ),
                      const SizedBox(height: 40),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue.withOpacity(0.8), size: 24),
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