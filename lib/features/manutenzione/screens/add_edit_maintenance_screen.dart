import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:myscooter/features/manutenzione/models/manutenzione.dart';
import 'package:myscooter/features/manutenzione/providers/manutenzione_provider.dart';
import 'package:myscooter/core/providers/currency_provider.dart';
import 'package:myscooter/core/providers/message_provider.dart';
import 'package:myscooter/core/services/cloud_storage_manager.dart';
import 'package:myscooter/core/services/local_image_cache.dart';
import 'package:myscooter/l10n/app_localizations.dart';

class AddEditMaintenanceScreen extends ConsumerStatefulWidget {
  final String scooterId;
  final Manutenzione? manutenzione;

  const AddEditMaintenanceScreen({super.key, required this.scooterId, this.manutenzione});

  @override
  ConsumerState<AddEditMaintenanceScreen> createState() => _AddEditMaintenanceScreenState();
}

class _AddEditMaintenanceScreenState extends ConsumerState<AddEditMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _titoloController;
  late DateTime _data;
  late TextEditingController _kmController;
  late CategoriaManutenzione _categoria;
  late TextEditingController _categoriaCustomController;
  late TextEditingController _costoController;
  late TextEditingController _noteController;

  String? _currentImgName;
  File? _newImageFile;

  @override
  void initState() {
    super.initState();
    final m = widget.manutenzione;
    _titoloController = TextEditingController(text: m?.titolo ?? '');
    _data = m?.data ?? DateTime.now();
    _kmController = TextEditingController(text: m != null ? m.km.toString().replaceAll('.0', '') : '');
    _categoria = m?.categoria ?? CategoriaManutenzione.motore;
    _categoriaCustomController = TextEditingController(text: m?.categoriaCustom ?? '');
    _costoController = TextEditingController(text: m?.costo != null ? m!.costo.toString() : '');
    _noteController = TextEditingController(text: m?.note ?? '');

    _currentImgName = m?.nomeFoto != null ? p.basename(m!.nomeFoto!) : null;
  }

  @override
  void dispose() {
    _titoloController.dispose();
    _kmController.dispose();
    _categoriaCustomController.dispose();
    _costoController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selezionaData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _data) setState(() => _data = picked);
  }

  Future<void> _scegliFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() => _newImageFile = File(pickedFile.path));
    }
  }

  String _translateCategory(CategoriaManutenzione cat, AppLocalizations l10n) {
    switch (cat) {
      case CategoriaManutenzione.motore: return l10n.cat_motore;
      case CategoriaManutenzione.accensione: return l10n.cat_accensione;
      case CategoriaManutenzione.alimentazione: return l10n.cat_alimentazione;
      case CategoriaManutenzione.olioCambio: return l10n.cat_olio_cambio;
      case CategoriaManutenzione.trasmissione: return l10n.cat_trasmissione;
      case CategoriaManutenzione.freniGomme: return l10n.cat_freni_gomme;
      case CategoriaManutenzione.carrozzeria: return l10n.cat_carrozzeria;
      case CategoriaManutenzione.altro: return l10n.cat_altro;
    }
  }

  double? _parseNumber(String value) {
    if (value.isEmpty) return null;
    return double.tryParse(value.replaceAll(',', '.').trim());
  }

  Future<void> _salvaDati() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    String? finalImgName = _currentImgName;
    final appDir = await getApplicationDocumentsDirectory();

    try {
      if (_newImageFile != null) {
        final fileName = 'maint_${DateTime.now().millisecondsSinceEpoch}${p.extension(_newImageFile!.path)}';
        final savedImage = await _newImageFile!.copy(p.join(appDir.path, fileName));
        finalImgName = fileName;

        CloudStorageManager.shared.uploadImageSilently(fileName: fileName, localFile: savedImage);

        if (_currentImgName != null) {
          final oldFile = File(p.join(appDir.path, _currentImgName!));
          if (await oldFile.exists()) await oldFile.delete();
          CloudStorageManager.shared.deleteImageSilently(fileName: _currentImgName!);
        }
      } else if (_currentImgName == null && widget.manutenzione?.nomeFoto != null) {
        final oldFileName = p.basename(widget.manutenzione!.nomeFoto!);
        final oldFile = File(p.join(appDir.path, oldFileName));
        if (await oldFile.exists()) await oldFile.delete();
        CloudStorageManager.shared.deleteImageSilently(fileName: oldFileName);
      }

      final nuovaManutenzione = Manutenzione(
        id: widget.manutenzione?.id,
        scooterId: widget.scooterId,
        data: _data,
        km: _parseNumber(_kmController.text) ?? 0.0,
        categoria: _categoria,
        categoriaCustom: _categoria == CategoriaManutenzione.altro ? _categoriaCustomController.text : null,
        titolo: _titoloController.text.trim(),
        costo: _parseNumber(_costoController.text),
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        nomeFoto: finalImgName,
      );

      final actions = ref.read(manutenzioneActionsProvider);
      if (widget.manutenzione == null) {
        await actions.addManutenzione(nuovaManutenzione);
      } else {
        await actions.updateManutenzione(nuovaManutenzione);
      }

      if (mounted) {
        context.pop(nuovaManutenzione);
        ref.read(messageProvider.notifier).show(l10n.maintenanceSaved, type: MessageType.success);
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
    final currencySymbol = ref.watch(currencyProvider);
    final dateFormat = DateFormat('dd MMM yyyy', Localizations.localeOf(context).languageCode);

    final bool hasImage = _newImageFile != null || (_currentImgName != null && _currentImgName!.isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.manutenzione == null ? l10n.nuovoIntervento : l10n.modificaIntervento),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            IconButton(icon: const Icon(Icons.check, color: Colors.blue), onPressed: _salvaDati),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionHeader(l10n.infoPrincipali),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withAlpha(50))),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titoloController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(labelText: l10n.titoloIntervento, border: InputBorder.none),
                        validator: (val) => val == null || val.trim().isEmpty ? l10n.datiMancanti : null,
                      ),
                      const Divider(),
                      InkWell(
                        onTap: () => _selezionaData(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.dataIntervento, style: const TextStyle(fontSize: 16)),
                              Text(dateFormat.format(_data), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      TextFormField(
                        controller: _kmController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: l10n.currentKm, border: InputBorder.none, suffixText: "km"),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return l10n.datiMancanti;
                          if (_parseNumber(val) == null) return l10n.insertNumber;
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader(l10n.categoria),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withAlpha(50))),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<CategoriaManutenzione>(
                        // FIX: Usiamo initialValue al posto di value
                        initialValue: _categoria,
                        decoration: const InputDecoration(border: InputBorder.none),
                        isExpanded: true,
                        items: CategoriaManutenzione.values.map((cat) => DropdownMenuItem(value: cat, child: Text(_translateCategory(cat, l10n)))).toList(),
                        onChanged: (val) { if (val != null) setState(() => _categoria = val); },
                      ),
                      if (_categoria == CategoriaManutenzione.altro) ...[
                        const Divider(),
                        TextFormField(
                          controller: _categoriaCustomController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(labelText: l10n.specificaAltro, border: InputBorder.none),
                          validator: (val) => val == null || val.trim().isEmpty ? l10n.datiMancanti : null,
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader(l10n.dettagliAggiuntivi),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withAlpha(50))),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _costoController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: l10n.costoOpzionale, border: InputBorder.none, suffixText: currencySymbol),
                        validator: (val) {
                          if (val != null && val.isNotEmpty && _parseNumber(val) == null) return l10n.insertNumber;
                          return null;
                        },
                      ),
                      const Divider(),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(hintText: l10n.notePlaceholder, border: InputBorder.none),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader(l10n.fotoRicevuta),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withAlpha(50))),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: hasImage
                      ? Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _newImageFile != null
                            ? Image.file(_newImageFile!, width: 60, height: 60, fit: BoxFit.cover)
                            : CloudSyncImage(imagePath: _currentImgName, width: 60, height: 60, fit: BoxFit.cover),
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
                        child: Text(l10n.rimuoviFoto),
                      ),
                    ],
                  )
                      : InkWell(
                    onTap: _scegliFoto,
                    child: Row(
                      children: [
                        const Icon(Icons.photo_library_outlined, size: 32, color: Colors.grey),
                        const SizedBox(width: 16),
                        Text(l10n.selezionaFoto, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }
}