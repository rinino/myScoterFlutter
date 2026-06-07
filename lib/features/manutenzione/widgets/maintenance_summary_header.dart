import 'dart:ui'; // FIX PRO
import 'package:flutter/material.dart';
import 'package:myscooter/features/manutenzione/models/manutenzione.dart';
import 'package:myscooter/l10n/app_localizations.dart';
import '../../../core/widgets/custom_glass_card.dart'; // FIX PRO

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      // FIX PRO: Trasformato in una GlassCard!
      child: CustomGlassCard(
        borderColors: [
          Colors.orange.withOpacity(0.4),
          Colors.yellow.withOpacity(0.15),
          Colors.transparent,
        ],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(context, l10n.registroManutenzione, '$interventiTotali', Icons.history),
              _buildSummaryItem(
                  context,
                  l10n.costoOpzionale.replaceAll(' (Opzionale)', ''),
                  '${costoTotale.toStringAsFixed(2)} $currencySymbol',
                  Icons.account_balance_wallet
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange, size: 28),
        const SizedBox(height: 8),
        Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()], // FIX PRO: Numeri allineati
            )
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}