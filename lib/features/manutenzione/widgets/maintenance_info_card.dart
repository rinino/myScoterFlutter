import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myscooter/features/manutenzione/models/manutenzione.dart';
import 'package:myscooter/l10n/app_localizations.dart';

class MaintenanceInfoCard extends StatelessWidget {
  final Manutenzione manutenzione;
  final String currencySymbol;

  const MaintenanceInfoCard({
    super.key,
    required this.manutenzione,
    required this.currencySymbol,
  });

  String _translateCategory(CategoriaManutenzione cat, String? custom, AppLocalizations l10n) {
    if (cat == CategoriaManutenzione.altro && custom != null) {
      return custom;
    }
    switch (cat) {
      case CategoriaManutenzione.motore: return l10n.cat_motore;
      case CategoriaManutenzione.accensione: return l10n.cat_accensione;
      case CategoriaManutenzione.alimentazione: return l10n.cat_alimentazione;
      case CategoriaManutenzione.olioCambio: return l10n.cat_olio_cambio;
      case CategoriaManutenzione.trasmissione: return l10n.cat_trasmissione;
      case CategoriaManutenzione.freniGomme: return l10n.cat_freni_gomme;
      case CategoriaManutenzione.carrozzeria: return l10n.cat_carrozzeria;
      case CategoriaManutenzione.altro: return l10n.cat_altro;
    }
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMMM yyyy', Localizations.localeOf(context).languageCode);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    manutenzione.categoria.icon,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  dateFormat.format(manutenzione.data),
                  style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              manutenzione.titolo,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _translateCategory(manutenzione.categoria, manutenzione.categoriaCustom, l10n),
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary, fontStyle: FontStyle.italic),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ADR: Corrette le chiavi con currentKm e costoLabel
                _buildDetailItem(l10n.currentKm, "${manutenzione.km.toStringAsFixed(0)} km", Icons.speed),
                if (manutenzione.costo != null)
                  _buildDetailItem(l10n.costoLabel, "${manutenzione.costo!.toStringAsFixed(2)} $currencySymbol", Icons.payments_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }
}