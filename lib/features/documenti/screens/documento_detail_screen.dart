
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myscooter/l10n/app_localizations.dart';
import 'package:myscooter/core/services/local_image_cache.dart';
import '../../scooter/widgets/image_viewer_page.dart';
import '../models/documento.dart';

class DocumentoDetailScreen extends ConsumerStatefulWidget {
  final Documento documento;

  const DocumentoDetailScreen({super.key, required this.documento});

  @override
  ConsumerState<DocumentoDetailScreen> createState() => _DocumentoDetailScreenState();
}

class _DocumentoDetailScreenState extends ConsumerState<DocumentoDetailScreen> {
  late Documento _currentDocumento;

  @override
  void initState() {
    super.initState();
    _currentDocumento = widget.documento;
  }

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
    if (_currentDocumento.nomeFoto == null || _currentDocumento.nomeFoto!.isEmpty) return;

    Navigator.push(context, MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => ImageViewerPage(
        imagePath: _currentDocumento.nomeFoto!,
        title: _currentDocumento.tipo == TipoDocumento.altro ? (_currentDocumento.tipoCustom ?? 'Documento') : _currentDocumento.tipo.name,
        heroTag: 'doc_image_${_currentDocumento.id}',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM yyyy', Localizations.localeOf(context).languageCode);

    final bool hasImage = _currentDocumento.nomeFoto != null && _currentDocumento.nomeFoto!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.infoPrincipali),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () async {
              // Attendiamo il ritorno dalla schermata di modifica
              final result = await context.push('/add-edit-documento', extra: {
                'scooterId': _currentDocumento.scooterId,
                'documento': _currentDocumento,
              });

              // Se abbiamo salvato con successo, aggiorniamo l'interfaccia
              if (result != null && result is Documento) {
                setState(() {
                  _currentDocumento = result;
                });
              }
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
                  Icon(_currentDocumento.tipo.icon, size: 50, color: _getExpiryColor(_currentDocumento.dataScadenza)),
                  const SizedBox(height: 16),
                  Text(
                    _currentDocumento.tipo == TipoDocumento.altro ? (_currentDocumento.tipoCustom ?? l10n.cat_altro) : _currentDocumento.tipo.getLocalizedName(l10n).toUpperCase(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _currentDocumento.dataScadenza != null ? dateFormat.format(_currentDocumento.dataScadenza!) : l10n.senzaScadenza,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getExpiryColor(_currentDocumento.dataScadenza)
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_currentDocumento.note != null && _currentDocumento.note!.isNotEmpty) ...[
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
                    Text(_currentDocumento.note!, style: const TextStyle(fontSize: 16)),
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
                        tag: 'doc_image_${_currentDocumento.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CloudSyncImage(
                              imagePath: _currentDocumento.nomeFoto!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover
                          ),
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