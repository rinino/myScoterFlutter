import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myscooter/features/manutenzione/models/manutenzione.dart';
import 'package:myscooter/l10n/app_localizations.dart';

class MaintenancePhotoCard extends StatelessWidget {
  final Manutenzione manutenzione;
  final VoidCallback onTap;

  const MaintenancePhotoCard({
    super.key,
    required this.manutenzione,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    l10n.fotoRicevuta,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const Spacer(),
                  const Icon(Icons.zoom_in, color: Colors.grey, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Hero(
                  tag: 'maint_image_${manutenzione.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(manutenzione.nomeFoto!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
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