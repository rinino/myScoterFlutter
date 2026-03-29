import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myscooter/l10n/app_localizations.dart';

class LocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLon;

  const LocationPickerScreen({super.key, this.initialLat, this.initialLon});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  late LatLng _currentCenter;
  bool _hasCenteredOnUser = false;

  @override
  void initState() {
    super.initState();
    // Default a Potenza o alle coordinate passate (come avevamo fatto in iOS)
    _currentCenter = (widget.initialLat != null && widget.initialLon != null)
        ? LatLng(widget.initialLat!, widget.initialLon!)
        : const LatLng(40.6395, 15.8055);
  }

  // Funzione per richiedere i permessi e centrare la mappa sulla posizione attuale
  Future<void> _centerOnUser() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    final newCenter = LatLng(position.latitude, position.longitude);

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newCenter, 16.0));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selezionaSullaMappa),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnUser,
          )
        ],
      ),
      body: Stack(
        children: [
          // 1. La Mappa Google
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentCenter,
              zoom: 16.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              // Se è un nuovo rifornimento (no coordinate passate), centramo subito sull'utente
              if (widget.initialLat == null && !_hasCenteredOnUser) {
                _centerOnUser();
                _hasCenteredOnUser = true;
              }
            },
            onCameraMove: (position) {
              // Aggiorniamo costantemente la variabile mentre l'utente sposta la mappa
              _currentCenter = position.target;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Abbiamo il nostro bottone nell'AppBar
            zoomControlsEnabled: false,
          ),

          // 2. Il Pin fisso esattamente al centro dello schermo
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 45.0), // Compensa l'altezza dell'icona per far coincidere la punta al centro
              child: Icon(
                Icons.location_on,
                size: 50.0,
                color: Colors.red,
                shadows: [Shadow(color: Colors.black45, blurRadius: 5, offset: Offset(0, 3))],
              ),
            ),
          ),

          // 3. Il bottone di Conferma in basso
          Positioned(
            bottom: 30.0,
            left: 20.0,
            right: 20.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 4,
              ),
              onPressed: () {
                // Restituiamo le coordinate scelte alla schermata precedente
                Navigator.pop(context, _currentCenter);
              },
              child: Text(
                l10n.confermaPosizione,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}