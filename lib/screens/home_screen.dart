import 'package:flutter/material.dart';
import 'package:myscoterflutter/models/scooter.dart';
import 'package:myscoterflutter/repository/scooter_repository.dart';
import 'package:myscoterflutter/screens/add_edit_scooter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScooterRepository _scooterRepository = ScooterRepository();
  List<Scooter> _scooters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScooters(); // Carica gli scooter all'avvio della schermata
  }

  // Funzione per caricare gli scooter dal repository
  Future<void> _loadScooters() async {
    setState(() {
      _isLoading = true; // Imposta lo stato di caricamento
    });
    try {
      final scooters = await _scooterRepository.getAllScooters();
      setState(() {
        _scooters = scooters; // Aggiorna la lista degli scooter
        _isLoading = false; // Termina lo stato di caricamento
      });
    } catch (e) {
      print('Errore nel caricamento degli scooter: $e');
      setState(() {
        _isLoading =
            false; // Termina lo stato di caricamento anche in caso di errore
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore nel caricamento degli scooter.')),
      );
    }
  }

  // Funzione per eliminare uno scooter
  Future<void> _deleteScooter(int id) async {
    // Opzionale: mostra una dialog di conferma
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma eliminazione'),
          content: const Text('Sei sicuro di voler eliminare questo scooter?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Elimina', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _scooterRepository.deleteScooter(id);
        _loadScooters(); // Ricarica la lista dopo l'eliminazione
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Scooter eliminato!')));
      } catch (e) {
        print('Errore nell\'eliminazione dello scooter: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore nell\'eliminazione dello scooter.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        // Column per impilare verticalmente immagine, titolo, pulsante e lista
        children: [
          // Sezione Superiore: Immagine e Pulsante '+'
          Stack(
            // Stack per sovrapporre l'immagine e il pulsante '+'
            alignment:
                Alignment.topRight, // Allinea il contenuto in alto a destra
            children: [
              // Immagine di Intestazione
              Image.asset(
                'assets/images/scooter_header.png', // Percorso della tua immagine
                width: double.infinity, // Occupa tutta la larghezza disponibile
                height: 200, // Altezza fissa per l'immagine
                fit: BoxFit.cover, // Copre l'area mantenendo le proporzioni
              ),
              // Pulsante '+' posizionato in alto a destra
              Padding(
                padding: const EdgeInsets.all(16.0), // Spazio dall'angolo
                child: FloatingActionButton(
                  onPressed: () async {
                    // Naviga alla schermata di aggiunta scooter e attendi il risultato
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditScooterScreen(),
                      ),
                    );
                    // Se uno scooter è stato aggiunto/modificato, ricarica la lista
                    if (result == true) {
                      _loadScooters();
                    }
                  },
                  heroTag: 'addScooterButton', // Importante se hai più FAB
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),

          // Titolo "I Miei Scooter"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              // Allinea il testo a sinistra (default è center per Text)
              alignment: Alignment.centerLeft,
              child: Text(
                'I Miei Scooter',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
            ),
          ),

          // Sezione della Lista degli Scooter
          Expanded(
            // Expanded fa sì che la lista occupi lo spazio rimanente
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  ) // Mostra un loader durante il caricamento
                : _scooters.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.two_wheeler,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nessuno scooter disponibile.\nPremi "+" per aggiungerne uno!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _scooters.length,
                    itemBuilder: (context, index) {
                      final scooter = _scooters[index];
                      return Card(
                        // Usa Card per un aspetto più pulito
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        elevation: 4.0,
                        child: ListTile(
                          leading: CircleAvatar(
                            // Se hai un'immagine, la mostri qui. Altrimenti, una lettera o icona.
                            // Per ora, usiamo la prima lettera della marca.
                            backgroundColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.2),
                            child: Text(
                              scooter.marca[0].toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            // Se avrai un'immagine, potresti usare:
                            // backgroundImage: scooter.imgPath != null
                            //     ? FileImage(File(scooter.imgPath!)) // Richiede import 'dart:io'
                            //     : null,
                            // child: scooter.imgPath == null
                            //     ? Icon(Icons.image, color: Theme.of(context).primaryColor)
                            //     : null,
                          ),
                          title: Text('${scooter.marca} ${scooter.modello}'),
                          subtitle: Text(
                            'Targa: ${scooter.targa} - Cilindrata: ${scooter.cilindrata}cc',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize
                                .min, // Occupa solo lo spazio necessario
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  // Naviga alla schermata di modifica scooter
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddEditScooterScreen(
                                            scooter: scooter,
                                          ),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadScooters(); // Ricarica la lista dopo la modifica
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteScooter(scooter.id!),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Potresti navigare a una schermata di dettaglio dello scooter qui
                            print('Tapped on: ${scooter.modello}');
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
