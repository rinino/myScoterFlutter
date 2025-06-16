import 'package:flutter/material.dart';
import 'package:myscoterflutter/models/scooter.dart';
import 'package:myscoterflutter/repository/scooter_repository.dart';
import 'package:myscoterflutter/screens/add_edit_scooter_screen.dart';
import 'package:myscoterflutter/screens/scooter_detail_screen.dart'; // Importa la nuova schermata di dettaglio

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Inizializza il repository per la gestione dei dati degli scooter
  final ScooterRepository _scooterRepository = ScooterRepository();
  List<Scooter> _scooters = []; // Lista per contenere gli scooter recuperati dal database
  bool _isLoading = true; // Flag per gestire lo stato di caricamento

  @override
  void initState() {
    super.initState();
    _loadScooters(); // Carica gli scooter all'avvio della schermata
  }

  /// Carica la lista degli scooter dal database.
  Future<void> _loadScooters() async {
    setState(() {
      _isLoading = true; // Imposta lo stato di caricamento su true
    });
    try {
      final scooters = await _scooterRepository.getAllScooters(); // Recupera tutti gli scooter
      setState(() {
        _scooters = scooters; // Aggiorna la lista degli scooter nello stato
        _isLoading = false; // Imposta lo stato di caricamento su false
      });
    } catch (e) {
      // Gestione degli errori durante il caricamento
      print('Errore nel caricamento degli scooter: $e');
      setState(() {
        _isLoading = false; // Assicura che l'indicatore di caricamento scompaia anche in caso di errore
      });
      // Mostra una SnackBar per informare l'utente dell'errore
      if (mounted) { // Controlla se il widget è ancora montato prima di mostrare la SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nel caricamento degli scooter.')),
        );
      }
    }
  }

  /// Gestisce l'eliminazione di uno scooter dopo una conferma.
  Future<void> _deleteScooter(int id) async {
    // Mostra un AlertDialog per richiedere conferma all'utente
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma eliminazione'),
          content: const Text('Sei sicuro di voler eliminare questo scooter? Tutti i rifornimenti associati verranno eliminati.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Annulla
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Conferma eliminazione
              child: const Text('Elimina', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) { // Se l'utente ha confermato
      try {
        await _scooterRepository.deleteScooter(id); // Elimina lo scooter dal database
        _loadScooters(); // Ricarica la lista degli scooter per aggiornare la UI
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scooter eliminato!')),
          );
        }
      } catch (e) {
        // Gestione degli errori durante l'eliminazione
        print('Errore nell\'eliminazione dello scooter: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Errore nell\'eliminazione dello scooter.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Scooter'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        centerTitle: false,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
        child: FloatingActionButton(
          onPressed: () async {
            // Naviga alla schermata di aggiunta/modifica scooter.
            // Aspetta il risultato (lo scooter eventualmente aggiunto)
            final Scooter? resultScooter = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEditScooterScreen(),
              ),
            );
            // Se uno scooter è stato aggiunto (non null)
            if (resultScooter != null) {
              try {
                await _scooterRepository.insertScooter(resultScooter); // Inserisci il nuovo scooter
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scooter aggiunto!')),
                  );
                }
                _loadScooters(); // Ricarica la lista per mostrare il nuovo scooter
              } catch (e) {
                print('Errore nell\'aggiunta dello scooter: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Errore nell\'aggiunta dello scooter.')),
                  );
                }
              }
            }
          },
          heroTag: 'addScooterButton', // Tag unico per il FloatingActionButton
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          // Sezione per l'immagine del logo (come nel tuo codice originale)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              width: 115,
              height: 115,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(11.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  'assets/images/loghetto1_scritta128.jpg', // Assicurati che il percorso dell'immagine sia corretto e che l'immagine esista nei tuoi assets
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Titolo "I Miei Scooter"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'I Miei Scooter',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Area principale con la lista degli scooter o messaggi di stato
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(), // Mostra un indicatore di caricamento
            )
                : _scooters.isEmpty
                ? Center(
              // Messaggio se non ci sono scooter
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.two_wheeler, // Icona dello scooter
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nessuno scooter disponibile.\nPremi "+" per aggiungerne uno!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7)),
                  ),
                ],
              ),
            )
                : ListView.builder(
              // Costruisce la lista degli scooter
              itemCount: _scooters.length,
              itemBuilder: (context, index) {
                final scooter = _scooters[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  elevation: 4.0,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .primaryColor
                          .withOpacity(0.2),
                      child: Text(
                        scooter.marca[0].toUpperCase(), // Prima lettera della marca
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    title: Text('${scooter.marca} ${scooter.modello}'),
                    subtitle: Text(
                      'Targa: ${scooter.targa} - Cilindrata: ${scooter.cilindrata}cc',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // Occupa solo lo spazio necessario
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () async {
                            // Naviga alla schermata di modifica scooter, passando lo scooter corrente
                            final Scooter? resultScooter = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddEditScooterScreen(
                                      scooter: scooter, // Passa lo scooter da modificare
                                    ),
                              ),
                            );
                            // Se lo scooter è stato modificato (non null)
                            if (resultScooter != null) {
                              try {
                                await _scooterRepository.updateScooter(resultScooter); // Aggiorna lo scooter
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Scooter modificato!')),
                                  );
                                }
                                _loadScooters(); // Ricarica la lista
                              } catch (e) {
                                print('Errore nella modifica dello scooter: $e');
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Errore nella modifica dello scooter.')),
                                  );
                                }
                              }
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteScooter(scooter.id!), // Chiama la funzione di eliminazione
                        ),
                      ],
                    ),
                    // Quando si tocca un elemento della lista, naviga alla schermata di dettaglio
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ScooterDetailScreen(scooter: scooter), // Passa lo scooter alla schermata di dettaglio
                        ),
                      ).then((_) => _loadScooters()); // Ricarica gli scooter quando si torna indietro dalla schermata di dettaglio (utile se si è modificato qualcosa lì)
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