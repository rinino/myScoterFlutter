import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../model/scooter.dart';

// FIX: Importiamo i Colori e la GlassCard
import 'package:myscooter/core/theme/app_colors.dart';
import 'package:myscooter/core/widgets/glass_card.dart';

class ScooterInfoCard extends StatelessWidget {
  final Scooter scooter;
  const ScooterInfoCard({super.key, required this.scooter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final iconColor = AppColors.primaryBlue;

    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _detailRow(Icons.sell, l10n.brand, scooter.marca, iconColor),
          const Divider(height: 24),
          _detailRow(Icons.moped, l10n.model, scooter.modello, iconColor),
          const Divider(height: 24),
          _detailRow(Icons.calendar_today, l10n.year, scooter.anno.toString(), iconColor),
          const Divider(height: 24),
          _detailRow(Icons.badge, l10n.licensePlate, scooter.targa, iconColor),
          const Divider(height: 24),
          _detailRow(Icons.engineering, l10n.displacement, '${scooter.cilindrata} cc', iconColor),
          const Divider(height: 24),
          _detailRow(Icons.water_drop, l10n.mixer, scooter.miscelatore ? l10n.yes : l10n.no, iconColor),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor.withOpacity(0.8), size: 22),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}