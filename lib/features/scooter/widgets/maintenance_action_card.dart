import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../model/scooter.dart';

class MaintenanceActionCard extends StatelessWidget {
  final Scooter scooter;

  const MaintenanceActionCard({super.key, required this.scooter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Naviga verso la rotta della manutenzione che abbiamo registrato in Fase 4
          context.push('/maintenance/${scooter.id!}', extra: scooter);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1), // Colore arancione per distinguerlo
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.build, // Chiave inglese
                  size: 28,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.registroManutenzione, // Usa la chiave L10n inserita in Fase 3
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}