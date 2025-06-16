// lib/screens/add_edit_scooter_screen.dart
import 'package:flutter/material.dart';
import 'package:myscoterflutter/models/scooter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart'; // Importa per CupertinoSwitch

class AddEditScooterScreen extends StatefulWidget {
  final Scooter? scooter;

  const AddEditScooterScreen({super.key, this.scooter});

  @override
  State<AddEditScooterScreen> createState() => _AddEditScooterScreenState();
}

class _AddEditScooterScreenState extends State<AddEditScooterScreen> {
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modelloController = TextEditingController();
  final TextEditingController _cilindrataController = TextEditingController();
  final TextEditingController _targaController = TextEditingController();
  final TextEditingController _annoController = TextEditingController();
  bool _miscelatore = false;

  File? _selectedImage;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.scooter != null) {
      _marcaController.text = widget.scooter!.marca;
      _modelloController.text = widget.scooter!.modello;
      _cilindrataController.text = widget.scooter!.cilindrata.toString();
      _targaController.text = widget.scooter!.targa;
      _annoController.text = widget.scooter!.anno.toString();
      _miscelatore = widget.scooter!.miscelatore;
      if (widget.scooter!.imgPath != null) {
        _selectedImage = File(widget.scooter!.imgPath!);
      }
    }
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _saveScooter() {
    if (_formKey.currentState!.validate()) {
      final String marca = _marcaController.text.trim();
      final String modello = _modelloController.text.trim();
      final int cilindrata = int.tryParse(_cilindrataController.text.trim()) ?? 0;
      final String targa = _targaController.text.trim();
      final int anno = int.tryParse(_annoController.text.trim()) ?? 0;

      final Scooter newOrUpdatedScooter = Scooter(
        id: widget.scooter?.id,
        marca: marca,
        modello: modello,
        cilindrata: cilindrata,
        targa: targa,
        anno: anno,
        miscelatore: _miscelatore,
        imgPath: _selectedImage?.path,
      );

      Navigator.pop(context, newOrUpdatedScooter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color titleColor = Theme.of(context).textTheme.headlineMedium?.color ?? Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.scooter == null ? 'Aggiungi Nuovo Scooter' : 'Modifica Scooter',
          style: TextStyle(color: titleColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveScooter,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Contenitore grigio per i campi di testo e il miscelatore
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _marcaController,
                      decoration: const InputDecoration(
                        labelText: 'Marca',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci la marca dello scooter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _modelloController,
                      decoration: const InputDecoration(
                        labelText: 'Modello',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci il modello dello scooter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _cilindrataController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cilindrata (cc)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci la cilindrata';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Inserisci un numero valido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _targaController,
                      decoration: const InputDecoration(
                        labelText: 'Targa',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci la targa dello scooter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _annoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Anno',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci l\'anno';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Inserisci un anno valido';
                        }
                        final int? annoInt = int.tryParse(value);
                        if (annoInt != null && (annoInt < 1900 || annoInt > DateTime.now().year + 1)) {
                          return 'Anno non valido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Miscelatore',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CupertinoSwitch(
                          value: _miscelatore,
                          onChanged: (bool newValue) {
                            setState(() {
                              _miscelatore = newValue;
                            });
                          },
                          activeTrackColor: CupertinoColors.activeGreen,
                          inactiveTrackColor: CupertinoColors.systemGrey3,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Selezionatore Immagine racchiuso in un box uguale
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade700),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: _selectedImage != null
                          ? Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Seleziona Immagine',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Contenitore grigio per i pulsanti "Salva" e "Annulla"
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[850], // Sfondo grigio scuro
                  borderRadius: BorderRadius.circular(8.0), // Angoli arrotondati
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Allinea i pulsanti a sinistra
                  children: [
                    ElevatedButton(
                      onPressed: _saveScooter,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        backgroundColor: Theme.of(context).colorScheme.primary, // Colore primario dal tema
                        foregroundColor: Theme.of(context).colorScheme.onPrimary, // Colore testo sul primario
                        minimumSize: const Size(double.infinity, 0), // Per far sì che il bottone sia largo quanto la colonna
                      ),
                      child: const Align( // Allinea la scritta "Salva" a sinistra
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Salva', // Testo fisso "Salva"
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12), // Spazio tra i due pulsanti

                    // Pulsante "Annulla"
                    OutlinedButton( // Utilizziamo OutlinedButton per un aspetto diverso
                      onPressed: () {
                        Navigator.pop(context); // Semplicemente torna indietro senza salvare
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        side: const BorderSide(color: Colors.red), // Bordo rosso
                        foregroundColor: Colors.red, // Testo rosso
                        minimumSize: const Size(double.infinity, 0), // Per far sì che il bottone sia largo quanto la colonna
                      ),
                      child: const Align( // Allinea la scritta "Annulla" a sinistra
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Annulla',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}