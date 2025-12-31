import 'package:flutter/material.dart';
import 'package:myscoterflutter/models/scooter.dart';
import 'package:myscoterflutter/repository/scooter_repository.dart';
import 'package:myscoterflutter/screens/add_edit_scooter_screen.dart';
import 'package:myscoterflutter/screens/scooter_detail_screen.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScooterRepository _scooterRepository = ScooterRepository();
  List<Scooter> _scooters = [];
  bool _isLoading = true; // Indica il caricamento iniziale degli scooter
  bool _isProcessingAction = false; // Nuovo stato per bloccare l'UI durante operazioni (add/edit/delete)

  @override
  void initState() {
    super.initState();
    _loadScooters();
  }

  // Metodo per caricare gli scooter dal database
  Future<void> _loadScooters() async {
    setState(() {
      _isLoading = true; // Imposta lo stato di caricamento a true
    });
    try {
      final scooters = await _scooterRepository.getAllScooters();
      setState(() {
        _scooters = scooters;
        _isLoading = false; // Imposta lo stato di caricamento a false
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Imposta lo stato di caricamento a false anche in caso di errore
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nel caricamento degli scooter.')),
        );
      }
    }
  }

  // Metodo per eliminare uno scooter
  Future<void> _deleteScooter(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma eliminazione'),
          content: const Text('Sei sicuro di voler eliminare questo scooter? Tutti i rifornimenti associati verranno eliminati.'),
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
      setState(() {
        _isProcessingAction = true; // Blocca l'UI all'inizio dell'eliminazione
      });
      try {
        await _scooterRepository.deleteScooter(id);
        await _loadScooters(); // Await per assicurarsi che il ricaricamento sia completo prima di sbloccare
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scooter eliminato!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Errore nell\'eliminazione dello scooter.'),
            ),
          );
        }
      } finally {
        setState(() {
          _isProcessingAction = false; // Sblocca l'UI alla fine dell'operazione
        });
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
          onPressed: _isProcessingAction ? null : () async { // Disabilita il FAB se un'azione è in corso
            final Scooter? resultScooter = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEditScooterScreen(),
              ),
            );
            if (resultScooter != null) {
              setState(() {
                _isProcessingAction = true; // Blocca l'UI all'inizio dell'aggiunta
              });
              try {
                await _scooterRepository.insertScooter(resultScooter);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scooter aggiunto!')),
                  );
                }
                await _loadScooters(); // Await per assicurarsi che il ricaricamento sia completo
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Errore nell\'aggiunta dello scooter.')),
                  );
                }
              } finally {
                setState(() {
                  _isProcessingAction = false; // Sblocca l'UI alla fine dell'operazione
                });
              }
            }
          },
          heroTag: 'addScooterButton',
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack( // Usiamo uno Stack per sovrapporre il loading overlay
        children: [
          Column(
            children: [
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
                      'assets/images/loghetto1_scritta128.jpg',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, color: Colors.grey, size: 60),
                        );
                      },
                    ),
                  ),
                ),
              ),
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
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
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
                            ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: _scooters.length,
                  itemBuilder: (context, index) {
                    final scooter = _scooters[index];

                    bool hasValidImage = scooter.imgPath != null && File(scooter.imgPath!).existsSync();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      elevation: 4.0,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: hasValidImage
                              ? Colors.transparent
                              : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          child: ClipOval(
                            child: hasValidImage
                                ? Image.file(
                              File(scooter.imgPath!),
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.broken_image,
                                  size: 30,
                                  color: Theme.of(context).primaryColor,
                                );
                              },
                            )
                                : Icon(
                              Icons.no_photography,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        title: Text('${scooter.marca} ${scooter.modello}'),
                        subtitle: Text(
                          'Targa: ${scooter.targa} - Cilindrata: ${scooter.cilindrata}cc',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              onPressed: _isProcessingAction ? null : () async { // Disabilita il bottone se un'azione è in corso
                                final Scooter? resultScooter = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddEditScooterScreen(
                                          scooter: scooter,
                                        ),
                                  ),
                                );
                                if (resultScooter != null) {
                                  setState(() {
                                    _isProcessingAction = true; // Blocca l'UI all'inizio della modifica
                                  });
                                  try {
                                    await _scooterRepository.updateScooter(resultScooter);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Scooter modificato!')),
                                      );
                                    }
                                    await _loadScooters(); // Await per assicurarsi che il ricaricamento sia completo
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Errore nella modifica dello scooter.')),
                                      );
                                    }
                                  } finally {
                                    setState(() {
                                      _isProcessingAction = false; // Sblocca l'UI alla fine dell'operazione
                                    });
                                  }
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: _isProcessingAction ? null : () => _deleteScooter(scooter.id!), // Disabilita il bottone se un'azione è in corso
                            ),
                          ],
                        ),
                        onTap: _isProcessingAction ? null : () { // Disabilita il tap se un'azione è in corso
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ScooterDetailScreen(scooter: scooter),
                            ),
                          ).then((_) => _loadScooters());
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Spinner di caricamento che blocca l'interazione
          if (_isProcessingAction) // Mostra solo se un'azione è in corso
            ModalBarrier(
              color: Colors.black.withOpacity(0.5), // Sfondo semi-trasparente
              dismissible: false, // Impedisce la chiusura cliccando fuori
            ),
          if (_isProcessingAction) // Mostra lo spinner al centro
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}