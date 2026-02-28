import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../model/scooter.dart';

class ScooterInfoCard extends StatelessWidget {
  final Scooter scooter;

  const ScooterInfoCard({super.key, required this.scooter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final iconColor = Theme.of(context).colorScheme.primary;

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
            _detailRow(Icons.sell, l10n.brand, scooter.marca, iconColor),
            const Divider(),
            _detailRow(Icons.moped, l10n.model, scooter.modello, iconColor),
            const Divider(),
            _detailRow(Icons.engineering, l10n.displacement, '${scooter.cilindrata} cc', iconColor),
            const Divider(),
            _detailRow(Icons.water_drop, l10n.mixer, scooter.miscelatore ? l10n.yes : l10n.no, iconColor),
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
}