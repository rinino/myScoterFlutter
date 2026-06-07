import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../core/widgets/glass_background.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/custom_glass_card.dart'; // FIX PRO
import '../model/scooter.dart';
import '../../../core/services/cloud_storage_manager.dart';
import '../../../core/services/local_image_cache.dart';
import '../../../core/theme/app_colors.dart';

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
  bool _isProcessing = false;
  String? _currentImgName;
  File? _newImageFile;

  @override
  void initState() {
    super.initState();
    _marcaController = TextEditingController(text: widget.scooter?.marca ?? '');
    _modelloController = TextEditingController(text: widget.scooter?.modello ?? '');
    _cilindrataController = TextEditingController(
        text: (widget.scooter != null && widget.scooter!.cilindrata != 0) ? widget.scooter!.cilindrata.toString() : ''
    );
    _targaController = TextEditingController(text: widget.scooter?.targa ?? '');
    _annoController = TextEditingController(
        text: (widget.scooter != null && widget.scooter!.anno != 0) ? widget.scooter!.anno.toString() : ''
    );
    _miscelatore = widget.scooter?.miscelatore ?? false;
    _currentImgName = widget.scooter?.imgName != null ? p.basename(widget.scooter!.imgName!) : null;
  }

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedFile != null) {
      setState(() => _newImageFile = File(pickedFile.path));
    }
  }

  Future<void> _saveForm() async {
    if (_isProcessing) return;
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      setState(() => _isProcessing = true);
      String? finalImgName = _currentImgName;
      final appDir = await getApplicationDocumentsDirectory();

      try {
        if (_newImageFile != null) {
          final fileName = 'scooter_${DateTime.now().millisecondsSinceEpoch}${p.extension(_newImageFile!.path)}';
          final savedImage = await _newImageFile!.copy(p.join(appDir.path, fileName));
          finalImgName = fileName;
          CloudStorageManager.shared.uploadImageSilently(fileName: fileName, localFile: savedImage);
          if (_currentImgName != null) {
            final oldFile = File(p.join(appDir.path, _currentImgName!));
            if (await oldFile.exists()) await oldFile.delete();
            CloudStorageManager.shared.deleteImageSilently(fileName: _currentImgName!);
          }
        }
      } catch (e) {
        debugPrint("Errore salvataggio immagine: $e");
      }

      final newScooter = Scooter(
        id: widget.scooter?.id,
        marca: _marcaController.text.trim(),
        modello: _modelloController.text.trim(),
        cilindrata: int.tryParse(_cilindrataController.text) ?? 0,
        targa: _targaController.text.trim().toUpperCase(),
        anno: int.tryParse(_annoController.text) ?? 0,
        miscelatore: _miscelatore,
        imgName: finalImgName,
      );
      if (mounted) context.pop(newScooter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.scooter == null ? l10n.addScooter : l10n.editScooter),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 28),
          color: AppColors.primaryBlue,
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, size: 28),
            color: AppColors.primaryBlue,
            onPressed: _isProcessing ? null : () => _saveForm(),
          ),
        ],
      ),
      body: Stack(
        children: [
          const GlassBackground(
            primaryColor: AppColors.primaryBlue,
            secondaryColor: AppColors.secondaryCyan,
          ),
          SafeArea(
            child: AbsorbPointer(
              absorbing: _isProcessing,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    // FOTO PROFILO
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5), width: 2),
                          ),
                          child: _newImageFile != null
                              ? ClipOval(child: Image.file(_newImageFile!, fit: BoxFit.cover))
                              : (_currentImgName != null && _currentImgName!.isNotEmpty)
                              ? ClipOval(child: CloudSyncImage(imagePath: _currentImgName!, width: 120, height: 120, fit: BoxFit.cover))
                              : const Icon(Icons.camera_alt, size: 40, color: AppColors.primaryBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // BLOCCO 1: Info Generali (IN VETRO)
                    CustomGlassCard(
                      borderColors: [
                        Colors.blue.withOpacity(0.4),
                        Colors.cyan.withOpacity(0.15),
                        Colors.transparent,
                      ],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            _buildModernTextField(_marcaController, l10n.brand, Icons.branding_watermark, l10n),
                            const Divider(height: 1),
                            _buildModernTextField(_modelloController, l10n.model, Icons.moped, l10n),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // BLOCCO 2: Dettagli Motore (IN VETRO)
                    CustomGlassCard(
                      borderColors: [
                        Colors.blue.withOpacity(0.4),
                        Colors.cyan.withOpacity(0.15),
                        Colors.transparent,
                      ],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            _buildModernTextField(_cilindrataController, '${l10n.displacement} (cc)', Icons.speed, l10n, isNumber: true),
                            const Divider(height: 1),
                            _buildModernTextField(
                                _targaController, l10n.licensePlate, Icons.badge, l10n,
                                isUppercase: true,
                                customValidator: (value) {
                                  if (value == null || value.trim().isEmpty) return l10n.requiredField;
                                  final targaRegex = RegExp(r'^[a-zA-Z0-9]{5,7}$');
                                  if (!targaRegex.hasMatch(value.replaceAll(' ', ''))) return l10n.invalidLicensePlate;
                                  return null;
                                }
                            ),
                            const Divider(height: 1),
                            _buildModernTextField(
                                _annoController, l10n.year, Icons.calendar_today, l10n,
                                isNumber: true,
                                customValidator: (value) {
                                  if (value == null || value.trim().isEmpty) return l10n.requiredField;
                                  final anno = int.tryParse(value);
                                  if (anno == null) return l10n.insertNumber;
                                  if (anno < 1900 || anno > DateTime.now().year) return l10n.invalidYear;
                                  return null;
                                }
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              title: Text(l10n.autoMixer, style: const TextStyle(fontWeight: FontWeight.w500)),
                              value: _miscelatore,
                              activeColor: AppColors.primaryBlue,
                              secondary: Icon(Icons.opacity, color: AppColors.primaryBlue.withOpacity(0.8)),
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                setState(() => _miscelatore = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildModernTextField(
      TextEditingController controller, String label, IconData icon, AppLocalizations l10n, {
        bool isNumber = false, bool isUppercase = false, String? Function(String?)? customValidator,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue.withOpacity(0.8), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: isNumber ? TextInputType.number : TextInputType.text,
              textCapitalization: isUppercase ? TextCapitalization.characters : TextCapitalization.none,
              style: isNumber ? const TextStyle(fontFeatures: [FontFeature.tabularFigures()]) : null, // FIX PRO: Numeri allineati nel form
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                isDense: true,
              ),
              validator: customValidator ?? (value) {
                if (value == null || value.trim().isEmpty) return l10n.requiredField;
                if (isNumber && int.tryParse(value) == null) return l10n.insertNumber;
                return null;
              },
            ),
          ),
        ],
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