import 'package:flutter/material.dart';
import 'package:myscoterflutter/models/scooter.dart';
import 'package:myscoterflutter/repository/scooter_repository.dart';
import 'package:myscoterflutter/screens/add_edit_scooter_screen.dart';
import 'package:flutter/cupertino.dart'; // Necessario per l'icona "two_wheeler" se non usi Material Icons


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
    _loadScooters();
  }

  Future<void> _loadScooters() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final scooters = await _scooterRepository.getAllScooters();
      setState(() {
        _scooters = scooters;
        _isLoading = false;
      });
    } catch (e) {
      print('Errore nel caricamento degli scooter: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore nel caricamento degli scooter.')),
      );
    }
  }

  Future<void> _deleteScooter(int id) async {
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
        _loadScooters();
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
            final Scooter? resultScooter = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEditScooterScreen(),
              ),
            );
            if (resultScooter != null) {
              try {
                await _scooterRepository.insertScooter(resultScooter);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scooter aggiunto!')),
                );
                _loadScooters();
              } catch (e) {
                print('Errore nell\'aggiunta dello scooter: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Errore nell\'aggiunta dello scooter.')),
                );
              }
            }
          },
          heroTag: 'addScooterButton',
          // --- QUI È LA MODIFICA: Colore del FloatingActionButton ---
          backgroundColor: Theme.of(context).colorScheme.primary, // Usa il colore primario del tema (#00bcd4)
          foregroundColor: Theme.of(context).colorScheme.onPrimary, // Colore dell'icona sul primario (bianco)
          // --- FINE MODIFICA ---
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
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
                        ?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
                  ),
                ],
              ),
            )
                : ListView.builder(
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
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.2),
                      child: Text(
                        scooter.marca[0].toUpperCase(),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () async {
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
                              try {
                                await _scooterRepository.updateScooter(resultScooter);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Scooter modificato!')),
                                );
                                _loadScooters();
                              } catch (e) {
                                print('Errore nella modifica dello scooter: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Errore nella modifica dello scooter.')),
                                );
                              }
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