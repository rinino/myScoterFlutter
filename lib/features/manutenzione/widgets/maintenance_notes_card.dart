import 'package:flutter/material.dart';
import 'package:myscooter/l10n/app_localizations.dart';

class MaintenanceNotesCard extends StatelessWidget {
  final String note;

  const MaintenanceNotesCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notes, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  l10n.noteDettagli,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              note,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}