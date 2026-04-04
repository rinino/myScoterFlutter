import 'package:flutter/material.dart';
import 'package:myscooter/features/manutenzione/models/manutenzione.dart';
import 'package:myscooter/l10n/app_localizations.dart';

class MaintenanceSummaryHeader extends StatelessWidget {
  final List<Manutenzione> manutenzioni;
  final String currencySymbol;

  const MaintenanceSummaryHeader({
    super.key,
    required this.manutenzioni,
    required this.currencySymbol
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double costoTotale = manutenzioni.fold(0, (sum, m) => sum + (m.costo ?? 0));
    final int interventiTotali = manutenzioni.length;

    return Container(
      padding: const EdgeInsets.all(16),
      // Corretto il warning con .withValues(alpha: ...)
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(context, l10n.registroManutenzione, '$interventiTotali', Icons.history),
          _buildSummaryItem(context, l10n.costoOpzionale.replaceAll(' (Opzionale)', ''),
              '${costoTotale.toStringAsFixed(2)} $currencySymbol', Icons.account_balance_wallet),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}