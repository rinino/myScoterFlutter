// lib/screens/add_edit_scooter_screen.dart
import 'package:flutter/material.dart';
import 'package:myscoterflutter/models/scooter.dart';

class AddEditScooterScreen extends StatefulWidget {
  // Questo campo 'scooter' è opzionale.
  // Se è presente, significa che stiamo modificando uno scooter esistente.
  // Se è null, stiamo aggiungendo un nuovo scooter.
  final Scooter? scooter;

  const AddEditScooterScreen({super.key, this.scooter});

  @override
  State<AddEditScooterScreen> createState() => _AddEditScooterScreenState();
}

class _AddEditScooterScreenState extends State<AddEditScooterScreen> {
  // Controller per i campi di testo. Saranno inizializzati con i dati dello scooter esistente (se c'è).
  // Li useremo più avanti. Per ora, li dichiariamo.
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modelloController = TextEditingController();
  final TextEditingController _cilindrataController = TextEditingController();
  final TextEditingController _targaController = TextEditingController();
  final TextEditingController _annoController = TextEditingController();
  bool _miscelatore = false; // Stato per il checkbox miscelatore

  // Una chiave per il form, utile per la validazione
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
    }
  }

  @override
  void dispose() {
    // È importante disporre dei controller quando il widget non è più usato
    _marcaController.dispose();
    _modelloController.dispose();
    _cilindrataController.dispose();
    _targaController.dispose();
    _annoController.dispose();
    super.dispose();
  }

  // Metodo per gestire il salvataggio dello scooter (lo implementeremo dopo)
  void _saveScooter() {
    if (_formKey.currentState!.validate()) {
      // Logica per salvare il nuovo scooter o aggiornare quello esistente
      // Per ora, stampiamo solo i valori
      print('Marca: ${_marcaController.text}');
      print('Modello: ${_modelloController.text}');
      print('Cilindrata: ${_cilindrataController.text}');
      print('Targa: ${_targaController.text}');
      print('Anno: ${_annoController.text}');
      print('Miscelatore: $_miscelatore');

      // Dopo il salvataggio, torna indietro alla schermata precedente
      Navigator.pop(
        context,
        true,
      ); // Passa 'true' per indicare che c'è stata una modifica/aggiunta
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.scooter == null
              ? 'Aggiungi Nuovo Scooter'
              : 'Modifica Scooter',
        ),
        // Puoi aggiungere un pulsante per il salvataggio qui, o alla fine del form
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveScooter),
        ],
      ),
      body: SingleChildScrollView(
        // Permette lo scroll se il contenuto supera l'altezza dello schermo
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // Il widget Form per la validazione degli input
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Estende i figli orizzontalmente
            children: [
              // Qui inseriremo i campi di input (TextField)
              // Per ora, solo un placeholder
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'Form per aggiungere/modificare lo scooter qui...',
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Placeholder per il bottone di salvataggio se non lo vuoi nell'AppBar
              // ElevatedButton(
              //   onPressed: _saveScooter,
              //   child: Text('Salva Scooter'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
