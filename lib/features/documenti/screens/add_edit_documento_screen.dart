import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:myscooter/l10n/app_localizations.dart';
import 'package:myscooter/core/providers/message_provider.dart';
import 'package:myscooter/core/services/cloud_storage_manager.dart';
import 'package:myscooter/core/services/local_image_cache.dart';

// FIX: Importiamo i Colori e il Glassmorphism
import 'package:myscooter/core/theme/app_colors.dart';

import '../../documenti/models/documento.dart';
import '../../documenti/providers/documento_provider.dart';
import '../../../core/widgets/glass_background.dart';
import '../../../core/widgets/glass_card.dart';

class AddEditDocumentoScreen extends ConsumerStatefulWidget {
  final String scooterId;
  final Documento? documento;

  const AddEditDocumentoScreen({super.key, required this.scooterId, this.documento});

  @override
  ConsumerState<AddEditDocumentoScreen> createState() => _AddEditDocumentoScreenState();
}

class _AddEditDocumentoScreenState extends ConsumerState<AddEditDocumentoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TipoDocumento _tipo;
  late TextEditingController _tipoCustomController;
  late bool _haScadenza;
  DateTime? _dataScadenza;
  late TextEditingController _noteController;

  String? _currentImgName;
  File? _newImageFile;

  @override
  void initState() {
    super.initState();
    final d = widget.documento;
    _tipo = d?.tipo ?? TipoDocumento.libretto;
    _tipoCustomController = TextEditingController(text: d?.tipoCustom ?? '');
    _haScadenza = d?.dataScadenza != null || d == null;
    _dataScadenza = d?.dataScadenza ?? DateTime.now().add(const Duration(days: 365));
    _noteController = TextEditingController(text: d?.note ?? '');
    _currentImgName = d?.nomeFoto != null ? p.basename(d!.nomeFoto!) : null;
  }

  @override
  void dispose() {
    _tipoCustomController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _scegliFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() => _newImageFile = File(pickedFile.path));
    }
  }

  Future<void> _salvaDati() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    String? finalImgName = _currentImgName;
    final appDir = await getApplicationDocumentsDirectory();

    try {
      if (_newImageFile != null) {
        final fileName = 'doc_${DateTime.now().millisecondsSinceEpoch}${p.extension(_newImageFile!.path)}';
        final savedImage = await _newImageFile!.copy(p.join(appDir.path, fileName));
        finalImgName = fileName;
        CloudStorageManager.shared.uploadImageSilently(fileName: fileName, localFile: savedImage);
        if (_currentImgName != null) {
          final oldFile = File(p.join(appDir.path, _currentImgName!));
          if (await oldFile.exists()) await oldFile.delete();
          CloudStorageManager.shared.deleteImageSilently(fileName: _currentImgName!);
        }
      } else if (_currentImgName == null && widget.documento?.nomeFoto != null) {
        final oldFileName = p.basename(widget.documento!.nomeFoto!);
        final oldFile = File(p.join(appDir.path, oldFileName));
        if (await oldFile.exists()) await oldFile.delete();
        CloudStorageManager.shared.deleteImageSilently(fileName: oldFileName);
      }

      final nuovoDocumento = Documento(
        id: widget.documento?.id,
        userId: widget.documento?.userId ?? FirebaseAuth.instance.currentUser?.uid,
        scooterId: widget.scooterId,
        tipo: _tipo,
        tipoCustom: _tipo == TipoDocumento.altro ? _tipoCustomController.text.trim() : null,
        dataScadenza: _haScadenza ? _dataScadenza : null,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        nomeFoto: finalImgName,
      );

      final actions = ref.read(documentoActionsProvider);
      if (widget.documento == null) {
        await actions.addDocumento(nuovoDocumento, l10n);
      } else {
        await actions.updateDocumento(nuovoDocumento, l10n);
      }

      if (mounted) {
        context.pop(nuovoDocumento);
        ref.read(messageProvider.notifier).show(l10n.documentSaved, type: MessageType.success);
      }
    } catch (e) {
      if (mounted) ref.read(messageProvider.notifier).show(l10n.errorSaving, type: MessageType.error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM yyyy', Localizations.localeOf(context).languageCode);
    final bool hasImage = _newImageFile != null || (_currentImgName != null && _currentImgName!.isNotEmpty);

    return Scaffold(
      backgroundColor: Colors.transparent, // FIX: Scaffold trasparente
      extendBodyBehindAppBar: true,        // FIX: Glass effect
      appBar: AppBar(
        title: Text(widget.documento == null ? l10n.aggiungi : l10n.modificaIntervento),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 28),
          color: AppColors.primaryDocument, // FIX: Icona Verde
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isSaving)
            const Padding(padding: EdgeInsets.only(right: 16), child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
          else
            IconButton(
                icon: const Icon(Icons.check, size: 28),
                color: AppColors.primaryDocument, // FIX: Icona Verde
                onPressed: _salvaDati
            ),
        ],
      ),
      body: Stack(
        children: [
          // FIX: Sfondo in vetro Verde
          const GlassBackground(
            primaryColor: AppColors.primaryDocument,
            secondaryColor: AppColors.secondaryDocument,
          ),

          SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionHeader(l10n.infoPrincipali),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.folder_special, color: AppColors.primaryDocument.withOpacity(0.8), size: 22),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<TipoDocumento>(
                                initialValue: _tipo,
                                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                                items: TipoDocumento.values.map((t) => DropdownMenuItem(value: t, child: Text(t.getLocalizedName(l10n)))).toList(),
                                onChanged: (val) { if (val != null) setState(() => _tipo = val); },
                              ),
                            ),
                          ],
                        ),
                        if (_tipo == TipoDocumento.altro) ...[
                          const Divider(height: 1),
                          _buildModernTextField(_tipoCustomController, l10n.specificaAltro, Icons.edit, l10n),
                        ],
                        const Divider(height: 1),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.haScadenza, style: const TextStyle(fontWeight: FontWeight.w500)),
                          value: _haScadenza,
                          activeColor: AppColors.primaryDocument,
                          onChanged: (val) => setState(() => _haScadenza = val),
                        ),
                        if (_haScadenza) ...[
                          const Divider(height: 1),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(context: context, initialDate: _dataScadenza!, firstDate: DateTime(2000), lastDate: DateTime(2100));
                              if (picked != null) setState(() => _dataScadenza = picked);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.event, color: AppColors.primaryDocument.withOpacity(0.8), size: 22),
                                  const SizedBox(width: 16),
                                  Text(l10n.dataScadenza, style: const TextStyle(fontSize: 16)),
                                  const Spacer(),
                                  Text(dateFormat.format(_dataScadenza!), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          )
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(l10n.noteLabel),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildModernTextField(_noteController, l10n.placeholderNote, Icons.notes, l10n, isRequired: false, maxLines: 3),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(l10n.fotoRicevuta),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: hasImage
                        ? Row(children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _newImageFile != null
                              ? Image.file(_newImageFile!, width: 60, height: 60, fit: BoxFit.cover)
                              : CloudSyncImage(imagePath: _currentImgName, width: 60, height: 60, fit: BoxFit.cover)
                      ),
                      const Spacer(),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              _newImageFile = null;
                              _currentImgName = null;
                            });
                          },
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: Text(l10n.rimuoviFoto)
                      ),
                    ])
                        : InkWell(
                        onTap: _scegliFoto,
                        child: Row(children: [
                          Icon(Icons.camera_alt, size: 32, color: AppColors.primaryDocument.withOpacity(0.8)),
                          const SizedBox(width: 16),
                          Text(l10n.selezionaFoto, style: const TextStyle(fontSize: 16)),
                        ])
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildModernTextField(
      TextEditingController controller, String label, IconData icon, AppLocalizations l10n, {
        bool isRequired = true, int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 12.0 : 0),
            child: Icon(icon, color: AppColors.primaryDocument.withOpacity(0.8), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                isDense: true,
              ),
              validator: (val) {
                if (isRequired && (val == null || val.trim().isEmpty)) return l10n.datiMancanti;
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}