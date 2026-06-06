import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../model/scooter.dart';

// FIX: Importiamo i Colori e la GlassCard
import 'package:myscooter/core/theme/app_colors.dart';
import 'package:myscooter/core/widgets/glass_card.dart';

class MaintenanceActionCard extends StatelessWidget {
  final Scooter scooter;
  const MaintenanceActionCard({super.key, required this.scooter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/maintenance/${scooter.id!}', extra: scooter);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryMaintenance.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.build, size: 28, color: AppColors.primaryMaintenance),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.registroManutenzione,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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