import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../model/scooter.dart';
import 'package:myscooter/core/theme/app_colors.dart';

class RefuelingsActionCard extends StatelessWidget {
  final Scooter scooter;

  const RefuelingsActionCard({super.key, required this.scooter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent, // FIX PRO: Abilita il ripple effect sul vetro
      child: InkWell(
        borderRadius: BorderRadius.circular(22.5),
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/refuelings/${scooter.id!}', extra: scooter);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_gas_station, size: 28, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.refuelingData,
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