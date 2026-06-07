import 'dart:ui'; // FIX PRO
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // FIX PRO
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myscooter/l10n/app_localizations.dart';
import 'package:myscooter/core/services/local_image_cache.dart';

import 'package:myscooter/core/theme/app_colors.dart';
import '../../../core/widgets/glass_background.dart';
import '../../../core/widgets/custom_glass_card.dart'; // FIX PRO
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
    final l10n = AppLocalizations.of(context)!;
    if (_currentDocumento.nomeFoto == null || _currentDocumento.nomeFoto!.isEmpty) return;
    HapticFeedback.lightImpact(); // FIX PRO
    Navigator.push(context, MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => ImageViewerPage(
        imagePath: _currentDocumento.nomeFoto!,
        title: _currentDocumento.tipo == TipoDocumento.altro ? (_currentDocumento.tipoCustom ?? l10n.documentoGenerico) : _currentDocumento.tipo.getLocalizedName(l10n),
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.infoPrincipali),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.green), // FIX PRO: Tema Verde
            onPressed: () async {
              HapticFeedback.lightImpact();
              final result = await context.push('/add-edit-documento', extra: {
                'scooterId': _currentDocumento.scooterId,
                'documento': _currentDocumento,
              });
              if (result != null && result is Documento) {
                setState(() {
                  _currentDocumento = result;
                });
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // FIX PRO: Sfondo in vetro Verde / Verde Menta
          const GlassBackground(
            primaryColor: Colors.green,
            secondaryColor: Colors.teal,
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // CARD 1: Info Principali
                CustomGlassCard(
                  borderColors: [
                    Colors.green.withOpacity(0.4),
                    Colors.teal.withOpacity(0.15),
                    Colors.transparent,
                  ],
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(_currentDocumento.tipo.icon, size: 50, color: _getExpiryColor(_currentDocumento.dataScadenza)),
                        const SizedBox(height: 16),
                        Text(
                          _currentDocumento.tipo == TipoDocumento.altro ? (_currentDocumento.tipoCustom ?? l10n.cat_altro) : _currentDocumento.tipo.getLocalizedName(l10n).toUpperCase(),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
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
                                color: _getExpiryColor(_currentDocumento.dataScadenza),
                                fontFeatures: const [FontFeature.tabularFigures()], // FIX PRO
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // CARD 2: Note
                if (_currentDocumento.note != null && _currentDocumento.note!.isNotEmpty) ...[
                  CustomGlassCard(
                    borderColors: [
                      Colors.green.withOpacity(0.4),
                      Colors.teal.withOpacity(0.15),
                      Colors.transparent,
                    ],
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

                // CARD 3: Foto
                if (hasImage) ...[
                  CustomGlassCard(
                    borderColors: [
                      Colors.green.withOpacity(0.4),
                      Colors.teal.withOpacity(0.15),
                      Colors.transparent,
                    ],
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22.5),
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
                                const Spacer(),
                                const Icon(Icons.zoom_in, color: Colors.grey, size: 20),
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
                    ),
                  )
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}