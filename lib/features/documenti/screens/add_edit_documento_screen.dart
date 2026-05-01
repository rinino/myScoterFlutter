import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:myscooter/l10n/app_localizations.dart';
import 'package:myscooter/core/providers/message_provider.dart';
import '../models/documento.dart';
import '../providers/documento_provider.dart';

class AddEditDocumentoScreen extends ConsumerStatefulWidget {
  final int scooterId;
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

  String? _imagePath;
  String? _oldImagePath;

  @override
  void initState() {
    super.initState();
    final d = widget.documento;
    _tipo = d?.tipo ?? TipoDocumento.libretto;
    _tipoCustomController = TextEditingController(text: d?.tipoCustom ?? '');
    _haScadenza = d?.dataScadenza != null || d == null; // Default true per i nuovi
    _dataScadenza = d?.dataScadenza ?? DateTime.now().add(const Duration(days: 365));
    _noteController = TextEditingController(text: d?.note ?? '');
    _imagePath = d?.nomeFoto;
    _oldImagePath = d?.nomeFoto;
  }

  @override
  void dispose() {
    _tipoCustomController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _deleteFile(String? path) async {
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
  }

  Future<void> _scegliFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'doc_${DateTime.now().millisecondsSinceEpoch}${p.extension(pickedFile.path)}';
      final savedImage = await File(pickedFile.path).copy(p.join(directory.path, fileName));

      if (_imagePath != null && _imagePath != _oldImagePath) {
        await _deleteFile(_imagePath);
      }
      setState(() => _imagePath = savedImage.path);
    }
  }

  Future<void> _salvaDati() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final nuovoDocumento = Documento(
      id: widget.documento?.id,
      idScooter: widget.scooterId,
      tipo: _tipo,
      tipoCustom: _tipo == TipoDocumento.altro ? _tipoCustomController.text.trim() : null,
      dataScadenza: _haScadenza ? _dataScadenza : null,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      nomeFoto: _imagePath,
    );

    try {
      final notifier = ref.read(documentoListProvider(widget.scooterId).notifier);
      if (widget.documento != null && _oldImagePath != null && _imagePath != _oldImagePath) {
        await _deleteFile(_oldImagePath);
      }

      if (widget.documento == null) {
        await notifier.addDocumento(nuovoDocumento);
      } else {
        await notifier.updateDocumento(nuovoDocumento);
      }

      if (mounted) {
        context.pop();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documento == null ? l10n.aggiungi : l10n.modificaIntervento),
        actions: [
          if (_isSaving)
            const Padding(padding: EdgeInsets.only(right: 16), child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
          else
            IconButton(icon: const Icon(Icons.check, color: Colors.blue), onPressed: _salvaDati),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.infoPrincipali.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<TipoDocumento>(
                      value: _tipo,
                      decoration: const InputDecoration(border: InputBorder.none),
                      items: TipoDocumento.values.map((t) => DropdownMenuItem(value: t, child: Text(t.getLocalizedName(l10n)))).toList(),
                      onChanged: (val) { if (val != null) setState(() => _tipo = val); },
                    ),
                    if (_tipo == TipoDocumento.altro) ...[
                      const Divider(),
                      TextFormField(
                        controller: _tipoCustomController,
                        decoration: InputDecoration(labelText: l10n.specificaAltro, border: InputBorder.none),
                        validator: (val) => val == null || val.trim().isEmpty ? l10n.datiMancanti : null,
                      ),
                    ],
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.haScadenza),
                      value: _haScadenza,
                      onChanged: (val) => setState(() => _haScadenza = val),
                    ),
                    if (_haScadenza) ...[
                      const Divider(),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(context: context, initialDate: _dataScadenza!, firstDate: DateTime(2000), lastDate: DateTime(2100));
                          if (picked != null) setState(() => _dataScadenza = picked);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(l10n.dataScadenza, style: const TextStyle(fontSize: 16)),
                            Text(dateFormat.format(_dataScadenza!), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.noteLabel.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(controller: _noteController, maxLines: 3, decoration: InputDecoration(hintText: l10n.placeholderNote, border: InputBorder.none)),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.fotoRicevuta.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _imagePath != null && File(_imagePath!).existsSync()
                    ? Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(_imagePath!), width: 60, height: 60, fit: BoxFit.cover)),
                  const Spacer(),
                  TextButton(onPressed: () async {
                    if (_imagePath != _oldImagePath) await _deleteFile(_imagePath);
                    setState(() => _imagePath = null);
                  }, style: TextButton.styleFrom(foregroundColor: Colors.red), child: Text(l10n.rimuoviFoto)),
                ])
                    : InkWell(onTap: _scegliFoto, child: Row(children: [
                  const Icon(Icons.camera_alt, size: 32, color: Colors.grey),
                  const SizedBox(width: 16),
                  Text(l10n.selezionaFoto, style: const TextStyle(fontSize: 16)),
                ])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}