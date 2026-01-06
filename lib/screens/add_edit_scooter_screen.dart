import 'package:flutter/material.dart';
import 'package:myscooter/models/scooter.dart';
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

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
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
    } else {
      _showErrorSnackBar('Controlla i campi evidenziati per errori.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color titleColor = Theme.of(context).textTheme.headlineMedium?.color ?? Colors.white;
    final Color detailTextColor = Colors.white70;

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
                      decoration: InputDecoration(
                        labelText: 'Marca',
                        hintText: 'Inserisci la marca',
                        labelStyle: TextStyle(color: detailTextColor),
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        filled: true,
                        fillColor: Colors.grey[800],
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La **Marca** è obbligatoria.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _modelloController,
                      decoration: InputDecoration(
                        labelText: 'Modello',
                        hintText: 'Inserisci il modello',
                        labelStyle: TextStyle(color: detailTextColor),
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        filled: true,
                        fillColor: Colors.grey[800],
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Il **Modello** è obbligatorio.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _cilindrataController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Cilindrata (cc)',
                        hintText: 'Inserisci la cilindrata',
                        labelStyle: TextStyle(color: detailTextColor),
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        filled: true,
                        fillColor: Colors.grey[800],
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La **Cilindrata** è obbligatoria.';
                        }
                        final int? cilindrata = int.tryParse(value);
                        if (cilindrata == null) {
                          return 'Inserisci un numero intero valido.';
                        }
                        if (cilindrata < 25) { // Nuovo limite inferiore
                          return 'La Cilindrata deve essere almeno **25cc**.';
                        }
                        if (cilindrata > 500) { // Nuovo limite superiore
                          return 'La Cilindrata deve essere al massimo **500cc**.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _targaController,
                      decoration: InputDecoration(
                        labelText: 'Targa',
                        hintText: 'Inserisci la targa (es. AA123BB)',
                        labelStyle: TextStyle(color: detailTextColor),
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        filled: true,
                        fillColor: Colors.grey[800],
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La **Targa** è obbligatoria.';
                        }
                        // Puoi aggiungere qui una RegEx per il formato della targa se vuoi
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _annoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Anno',
                        hintText: 'Inserisci l\'anno (es. 2020)',
                        labelStyle: TextStyle(color: detailTextColor),
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        filled: true,
                        fillColor: Colors.grey[800],
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'L\'**Anno** è obbligatorio.';
                        }
                        final int? anno = int.tryParse(value);
                        if (anno == null) {
                          return 'Inserisci un numero intero valido.';
                        }
                        final int currentYear = DateTime.now().year;
                        if (anno < 1900 || anno > currentYear + 1) {
                          return 'Inserisci un anno valido (es. **1900 - ${currentYear + 1}**).';
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