import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myscooter/core/theme/app_colors.dart';
import 'package:myscooter/core/widgets/custom_glass_card.dart';
import 'package:myscooter/features/rifornimento/models/rifornimento.dart';

import '../../../l10n/app_localizations.dart';

class ConsumiChartCard extends StatelessWidget {
  final List<Rifornimento> rifornimenti;

  const ConsumiChartCard({super.key, required this.rifornimenti});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Filtriamo solo quelli che hanno un consumo calcolato e li ordiniamo in modo cronologico crescente (dal vecchio al nuovo)
    final datiValidi = rifornimenti
        .where((r) => r.mediaConsumo != null && r.mediaConsumo! > 0)
        .toList()
      ..sort((a, b) => a.dataRifornimento.compareTo(b.dataRifornimento));

    // Se ci sono meno di 2 dati validi, non possiamo tracciare una linea
    if (datiValidi.length < 2) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: CustomGlassCard(
        borderColors: [
          Colors.blue.withOpacity(0.4),
          Colors.cyan.withOpacity(0.15),
          Colors.transparent,
        ],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights, color: AppColors.primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.andamentoConsumi, // Metti la stringa localizzata qui
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 160,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false), // Niente griglia per un look minimal
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Niente asse X
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false), // Niente bordi del grafico
                    lineBarsData: [
                      LineChartBarData(
                        spots: datiValidi.asMap().entries.map((entry) {
                          return FlSpot(entry.key.toDouble(), entry.value.mediaConsumo!);
                        }).toList(),
                        isCurved: true, // FIX PRO: Linea curva e sinuosa stile Apple
                        color: AppColors.primaryBlue,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false), // Nascondi i pallini sui nodi
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryBlue.withOpacity(0.3),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}