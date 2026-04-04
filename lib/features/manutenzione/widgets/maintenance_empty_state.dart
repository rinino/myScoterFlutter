import 'package:flutter/material.dart';
import 'package:myscooter/l10n/app_localizations.dart';

class MaintenanceEmptyState extends StatelessWidget {
  const MaintenanceEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Corretto il warning con .withValues(alpha: ...)
          Icon(Icons.build_circle_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            l10n.nessunaManutenzione,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}