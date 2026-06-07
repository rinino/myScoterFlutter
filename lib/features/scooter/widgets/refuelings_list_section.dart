import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // FIX PRO: Haptic Feedback
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../rifornimento/models/rifornimento.dart';

// Importiamo i Colori, la nuova CustomGlassCard e il Grafico
import 'package:myscooter/core/theme/app_colors.dart';
import 'package:myscooter/core/widgets/custom_glass_card.dart';
// Attenzione: verifica che il percorso di questo import corrisponda a dove hai salvato il grafico!
import 'package:myscooter/features/rifornimento/widgets/consumi_chart_card.dart';

class RefuelingsListSection extends StatelessWidget {
  final List<Rifornimento> rifornimenti;
  final bool isLoading;
  final String locale;
  final VoidCallback onAddTap;
  final Function(Rifornimento) onRifornimentoTap;
  final Function(Rifornimento) onDeleteConfirm;

  const RefuelingsListSection({
    super.key,
    required this.rifornimenti,
    required this.isLoading,
    required this.locale,
    required this.onAddTap,
    required this.onRifornimentoTap,
    required this.onDeleteConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- HEADER CON TITOLO E PULSANTE AGGIUNGI ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.refuelings, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey)),
            IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.primaryBlue),
                onPressed: () {
                  HapticFeedback.mediumImpact(); // FIX PRO: Vibrazione aggiunta
                  onAddTap();
                }
            ),
          ],
        ),

        const SizedBox(height: 8),

        // --- FIX PRO: IL GRAFICO DELLA DASHBOARD ---
        if (!isLoading && rifornimenti.isNotEmpty)
          ConsumiChartCard(rifornimenti: rifornimenti),

        // --- EMPTY STATE ---
        // --- EMPTY STATE INTERATTIVO (Stile Swift) ---
        if (!isLoading && rifornimenti.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CustomGlassCard(
              borderColors: [
                Colors.blue.withOpacity(0.4),
                Colors.cyan.withOpacity(0.15),
                Colors.transparent,
              ],
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22.5),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onAddTap();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_gas_station_outlined, size: 48, color: Colors.blue.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noDataPresent, // O una stringa tipo "Aggiungi il primo rifornimento"
                            style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // --- LISTA DEI RIFORNIMENTI ---
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rifornimenti.length,
          itemBuilder: (context, index) {
            final rif = rifornimenti[index];
            return Dismissible(
              key: Key(rif.id.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(22.5) // Arrotondato come la CustomGlassCard
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (dir) async {
                HapticFeedback.mediumImpact(); // Vibrazione prima di eliminare
                onDeleteConfirm(rif);
                return false;
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                // FIX PRO: Applicata la Glass Card Azzurra alle singole righe
                child: CustomGlassCard(
                  borderColors: [
                    Colors.blue.withOpacity(0.4),
                    Colors.cyan.withOpacity(0.15),
                    Colors.transparent,
                  ],
                  child: Material(
                    color: Colors.transparent, // Abilita l'effetto onda sul vetro
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              shape: BoxShape.circle
                          ),
                          child: const Icon(Icons.local_gas_station, color: AppColors.primaryBlue)
                      ),
                      title: Text(
                          DateFormat.yMMMd(locale).format(rif.dataRifornimento),
                          style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                      subtitle: Text(
                        '${rif.kmAttuali.toInt()} km - ${rif.mediaConsumo?.toStringAsFixed(2) ?? "N/A"} km/L',
                        style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]), // Numeri allineati
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        HapticFeedback.lightImpact(); // FIX PRO: Vibrazione dettaglio
                        onRifornimentoTap(rif);
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}