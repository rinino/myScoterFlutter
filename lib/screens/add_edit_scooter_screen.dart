import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myscooter/models/scooter.dart';

class AddEditScooterScreen extends StatefulWidget {
  final Scooter? scooter; // Se è nullo, stiamo aggiungendo. Se c'è, stiamo modificando.

  const AddEditScooterScreen({super.key, this.scooter});

  @override
  State<AddEditScooterScreen> createState() => _AddEditScooterScreenState();
}

class _AddEditScooterScreenState extends State<AddEditScooterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller per i campi di testo (come i tuoi @State in Swift)
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
    // Inizializzazione con dati esistenti (Edit) o vuoti (Add)
    _marcaController = TextEditingController(text: widget.scooter?.marca ?? '');
    _modelloController = TextEditingController(text: widget.scooter?.modello ?? '');
    _cilindrataController = TextEditingController(text: widget.scooter?.cilindrata?.toString() ?? '');
    _targaController = TextEditingController(text: widget.scooter?.targa ?? '');
    _annoController = TextEditingController(text: widget.scooter?.anno?.toString() ?? '');
    _miscelatore = widget.scooter?.miscelatore ?? false;

    if (widget.scooter?.imgPath != null) {
      _imageFile = File(widget.scooter!.imgPath!);
    }
  }

  // Logica Selezione Immagine (Simula PhotosPicker)
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

      // Creiamo l'oggetto scooter da restituire (come il saveNewScooterToDatabase in Swift)
      final newScooter = Scooter(
        id: widget.scooter?.id,
        marca: _marcaController.text,
        modello: _modelloController.text,
        cilindrata: int.tryParse(_cilindrataController.text) ?? 0,
        targa: _targaController.text,
        anno: int.tryParse(_annoController.text) ?? 0,
        miscelatore: _miscelatore,
        imgPath: _imageFile?.path,
      );

      // Simuliamo un piccolo ritardo per il feedback visivo
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context, newScooter);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scooter == null ? 'Nuovo Scooter' : 'Modifica'),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : _saveForm,
            child: const Text('Salva', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  // SEZIONE IMMAGINE
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

                  // SEZIONE DATI TECNICI (Stile Form iOS)
                  _buildSectionTitle('INFORMAZIONI GENERALI'),
                  _buildTextField(_marcaController, 'Marca', Icons.branding_watermark),
                  _buildTextField(_modelloController, 'Modello', Icons.moped),

                  const SizedBox(height: 16),
                  _buildSectionTitle('DETTAGLI'),
                  _buildTextField(_cilindrataController, 'Cilindrata (cc)', Icons.speed, isNumber: true),
                  _buildTextField(_targaController, 'Targa', Icons.badge),
                  _buildTextField(_annoController, 'Anno', Icons.calendar_today, isNumber: true),

                  const SizedBox(height: 16),
                  // TOGGLE MISCELATORE
                  SwitchListTile(
                    title: const Text('Miscelatore Automatico'),
                    subtitle: const Text('Attiva se lo scooter gestisce l\'olio da solo'),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Campo obbligatorio';
          if (isNumber && int.tryParse(value) == null) return 'Inserire un numero';
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