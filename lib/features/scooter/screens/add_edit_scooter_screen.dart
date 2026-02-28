// lib/features/scooter/screens/add_edit_scooter_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/app_localizations.dart';
import '../model/scooter.dart';


class AddEditScooterScreen extends StatefulWidget {
  final Scooter? scooter;

  const AddEditScooterScreen({super.key, this.scooter});

  @override
  State<AddEditScooterScreen> createState() => _AddEditScooterScreenState();
}

class _AddEditScooterScreenState extends State<AddEditScooterScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _marcaController;
  late TextEditingController _modelloController;
  late TextEditingController _cilindrataController;
  late TextEditingController _targaController;
  late TextEditingController _annoController;

  bool _miscelatore = false;
  File? _imageFile;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _marcaController = TextEditingController(text: widget.scooter?.marca ?? '');
    _modelloController = TextEditingController(text: widget.scooter?.modello ?? '');

    _cilindrataController = TextEditingController(
        text: (widget.scooter != null && widget.scooter!.cilindrata != 0)
            ? widget.scooter!.cilindrata.toString()
            : ''
    );

    _targaController = TextEditingController(text: widget.scooter?.targa ?? '');

    _annoController = TextEditingController(
        text: (widget.scooter != null && widget.scooter!.anno != 0)
            ? widget.scooter!.anno.toString()
            : ''
    );

    _miscelatore = widget.scooter?.miscelatore ?? false;

    if (widget.scooter?.imgPath != null) {
      _imageFile = File(widget.scooter!.imgPath!);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isProcessing = true);

      final newScooter = Scooter(
        id: widget.scooter?.id,
        marca: _marcaController.text.trim(),
        modello: _modelloController.text.trim(),
        cilindrata: int.tryParse(_cilindrataController.text) ?? 0,
        targa: _targaController.text.trim().toUpperCase(),
        anno: int.tryParse(_annoController.text) ?? 0,
        miscelatore: _miscelatore,
        imgPath: _imageFile?.path,
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context, newScooter);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scooter == null ? l10n.addScooter : l10n.editScooter),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : _saveForm,
            child: Text(l10n.save, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isProcessing,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: _imageFile != null
                            ? ClipOval(child: Image.file(_imageFile!, fit: BoxFit.cover))
                            : const Icon(Icons.camera_alt, size: 40, color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle(l10n.generalInfo),
                  _buildTextField(_marcaController, l10n.brand, Icons.branding_watermark, l10n),
                  _buildTextField(_modelloController, l10n.model, Icons.moped, l10n),

                  const SizedBox(height: 16),
                  _buildSectionTitle(l10n.details),

                  // CILINDRATA (Il controllo > 0 è nel validatore di default di _buildTextField)
                  _buildTextField(_cilindrataController, '${l10n.displacement} (cc)', Icons.speed, l10n, isNumber: true),

                  // TARGA (Validatore custom)
                  _buildTextField(
                      _targaController,
                      l10n.licensePlate,
                      Icons.badge,
                      l10n,
                      isUppercase: true, // Nuova flag per mostrare la tastiera in MAIUSCOLO
                      customValidator: (value) {
                        if (value == null || value.trim().isEmpty) return l10n.requiredField;

                        // Simula la tua "isValidTargaScooter": rimuove spazi e controlla se è lunga 5-7 caratteri alfanumerici
                        final cleanValue = value.replaceAll(' ', '');
                        final targaRegex = RegExp(r'^[a-zA-Z0-9]{5,7}$');
                        if (!targaRegex.hasMatch(cleanValue)) {
                          return l10n.invalidLicensePlate;
                        }
                        return null;
                      }
                  ),

                  // ANNO (Validatore custom)
                  _buildTextField(
                      _annoController,
                      l10n.year,
                      Icons.calendar_today,
                      l10n,
                      isNumber: true,
                      customValidator: (value) {
                        if (value == null || value.trim().isEmpty) return l10n.requiredField;

                        final anno = int.tryParse(value);
                        if (anno == null) return l10n.insertNumber;

                        // guard let anno = Int(nuovoAnnoString), anno >= 1900, anno <= Calendar.current.component(...)
                        final currentYear = DateTime.now().year;
                        if (anno < 1900 || anno > currentYear) {
                          return l10n.invalidYear;
                        }

                        return null;
                      }
                  ),

                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(l10n.autoMixer),
                    subtitle: Text(l10n.autoMixerDesc),
                    value: _miscelatore,
                    secondary: const Icon(Icons.opacity),
                    onChanged: (val) => setState(() => _miscelatore = val),
                  ),
                ],
              ),
            ),
          ),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      AppLocalizations l10n, {
        bool isNumber = false,
        bool isUppercase = false,
        String? Function(String?)? customValidator,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textCapitalization: isUppercase ? TextCapitalization.characters : TextCapitalization.none,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: customValidator ?? (value) {
          // Se non passi un customValidator, esegue questa logica di base (che avevamo scritto prima)
          if (value == null || value.trim().isEmpty) return l10n.requiredField;

          if (isNumber) {
            final parsedValue = int.tryParse(value);
            if (parsedValue == null) return l10n.insertNumber;
          }

          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modelloController.dispose();
    _cilindrataController.dispose();
    _targaController.dispose();
    _annoController.dispose();
    super.dispose();
  }
}