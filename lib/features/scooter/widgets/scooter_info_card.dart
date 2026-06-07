import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // FIX PRO: Haptic Feedback
import '../../../l10n/app_localizations.dart';
import '../model/scooter.dart';
import 'package:myscooter/core/theme/app_colors.dart';

// Trasformato in StatefulWidget per gestire l'apertura/chiusura (Accordion) come in Swift
class ScooterInfoCard extends StatefulWidget {
  final Scooter scooter;

  const ScooterInfoCard({super.key, required this.scooter});

  @override
  State<ScooterInfoCard> createState() => _ScooterInfoCardState();
}

class _ScooterInfoCardState extends State<ScooterInfoCard> {
  bool _isExpanded = false; // Controlla lo stato di apertura

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final iconColor = AppColors.primaryBlue;

    return Column(
      children: [
        // HEADER CLICCABILE
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22.5), // Rispetta il bordo della GlassCard padre
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.moped, color: AppColors.primaryBlue, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.scooter.modello,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Freccetta che ruota o cambia a seconda dello stato
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey.withOpacity(0.5),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),

        // CORPO ESPANDIBILE (Dettagli)
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity, height: 0),
          secondChild: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 8),
                _detailRow(Icons.sell, l10n.brand, widget.scooter.marca, iconColor),
                const Divider(height: 24, indent: 36),
                _detailRow(Icons.engineering, l10n.displacement, '${widget.scooter.cilindrata} cc', iconColor),
                const Divider(height: 24, indent: 36),
                _detailRow(Icons.badge, l10n.licensePlate, widget.scooter.targa, iconColor),
                const Divider(height: 24, indent: 36),
                _detailRow(Icons.calendar_today, l10n.year, widget.scooter.anno.toString(), iconColor),
                const Divider(height: 24, indent: 36),
                _detailRow(Icons.water_drop, l10n.mixer, widget.scooter.miscelatore ? l10n.yes : l10n.no, iconColor),
              ],
            ),
          ),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeOutCubic, // Curva morbida simile allo .spring() di iOS
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor.withOpacity(0.8), size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            fontFeatures: [FontFeature.tabularFigures()], // FIX PRO: Numeri allineati
          ),
        ),
      ],
    );
  }
}