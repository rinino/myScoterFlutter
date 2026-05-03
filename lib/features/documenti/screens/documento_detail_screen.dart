import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myscooter/l10n/app_localizations.dart';
import '../../scooter/widgets/image_viewer_page.dart';
import '../models/documento.dart';

class DocumentoDetailScreen extends ConsumerWidget {
  final Documento documento;

  const DocumentoDetailScreen({super.key, required this.documento});

  Color _getExpiryColor(DateTime? expiry) {
    if (expiry == null) return Colors.green;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiry.year, expiry.month, expiry.day);
    if (exp.isBefore(today) || exp.isAtSameMomentAs(today)) return Colors.red;
    if (exp.difference(today).inDays <= 30) return Colors.orange;
    return Colors.green;
  }

  void _openImageViewer(BuildContext context) {
    if (documento.nomeFoto == null || documento.nomeFoto!.isEmpty) return;

    final isNetwork = documento.nomeFoto!.startsWith('http');
    if (!isNetwork && !File(documento.nomeFoto!).existsSync()) return;

    Navigator.push(context, MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => ImageViewerPage(
        imagePath: documento.nomeFoto!,
        title: documento.tipo == TipoDocumento.altro ? (documento.tipoCustom ?? 'Documento') : documento.tipo.name,
        heroTag: 'doc_image_${documento.id}',
      ),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM yyyy', Localizations.localeOf(context).languageCode);

    // FIX: Calcola se c'è un'immagine disponibile (Cloud o Locale)
    final bool isNetwork = documento.nomeFoto != null && documento.nomeFoto!.startsWith('http');
    final bool hasImage = documento.nomeFoto != null && (isNetwork || File(documento.nomeFoto!).existsSync());

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.infoPrincipali),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              context.push('/add-edit-documento', extra: {
                'scooterId': documento.scooterId,
                'documento': documento,
              });
              context.pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(documento.tipo.icon, size: 50, color: _getExpiryColor(documento.dataScadenza)),
                  const SizedBox(height: 16),
                  Text(
                    documento.tipo == TipoDocumento.altro ? (documento.tipoCustom ?? l10n.cat_altro) : documento.tipo.getLocalizedName(l10n).toUpperCase(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        documento.dataScadenza != null ? dateFormat.format(documento.dataScadenza!) : l10n.senzaScadenza,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getExpiryColor(documento.dataScadenza)
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (documento.note != null && documento.note!.isNotEmpty) ...[
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.notes, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(l10n.noteLabel, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ]),
                    const SizedBox(height: 12),
                    Text(documento.note!, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (hasImage) ...[
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openImageViewer(context),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.image, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(l10n.fotoRicevuta, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ]),
                      const SizedBox(height: 16),
                      Hero(
                        tag: 'doc_image_${documento.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: isNetwork
                              ? Image.network(documento.nomeFoto!, height: 200, width: double.infinity, fit: BoxFit.cover)
                              : Image.file(File(documento.nomeFoto!), height: 200, width: double.infinity, fit: BoxFit.cover),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}