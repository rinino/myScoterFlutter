import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myscooter/models/scooter.dart';
import 'package:myscooter/repository/scooter_repository.dart';
import 'package:myscooter/screens/add_edit_scooter_screen.dart';
import 'package:myscooter/screens/scooter_detail_screen.dart';
import 'package:myscooter/screens/settings_screen.dart';
import '../service/theme_service.dart';

class HomeScreen extends StatefulWidget {
  final ThemeService themeService;

  const HomeScreen({super.key, required this.themeService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScooterRepository _scooterRepository = ScooterRepository();
  List<Scooter> _scooters = [];
  bool _isLoading = true;
  bool _isProcessingAction = false;

  @override
  void initState() {
    super.initState();
    _loadScooters();
  }

  // Caricamento dati iniziale
  Future<void> _loadScooters() async {
    setState(() => _isLoading = true);
    try {
      // Delay per emulare caricamento fluido (come da tua richiesta)
      await Future.delayed(const Duration(milliseconds: 800));
      final scooters = await _scooterRepository.getAllScooters();
      setState(() {
        _scooters = scooters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showSnackBar('Errore nel caricamento degli scooter.');
    }
  }

  // FUNZIONE CRITICA: Gestisce la cancellazione senza errori di "Dismissible"
  Future<void> _deleteScooter(Scooter scooter) async {
    // 1. Rimuoviamo IMMEDIATAMENTE dalla lista locale (Sincrono)
    // Questo evita l'errore "A dismissed Dismissible widget is still part of the tree"
    setState(() {
      _scooters.removeWhere((s) => s.id == scooter.id);
    });

    try {
      // 2. Operazioni asincrone (DB e File System)
      if (scooter.imgPath != null) {
        final file = File(scooter.imgPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      await _scooterRepository.deleteScooter(scooter.id!);

      if (mounted) _showSnackBar('Scooter "${scooter.modello}" eliminato.');
    } catch (e) {
      // In caso di errore, ricarichiamo la lista per ripristinare lo stato corretto
      await _loadScooters();
      if (mounted) _showSnackBar('Errore durante l\'eliminazione definitiva.');
    }
  }

  // Dialog di conferma prima dello swipe definitivo
  Future<bool?> _confirmDelete(Scooter scooter) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina Scooter'),
        content: Text('Sei sicuro di voler eliminare lo scooter ${scooter.modello}?\nQuesta azione cancellerà anche tutti i rifornimenti.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ANNULLA')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ELIMINA TUTTO', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToAddScooter() async {
    final Scooter? resultScooter = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditScooterScreen()),
    );

    if (resultScooter != null) {
      setState(() => _isProcessingAction = true);
      try {
        await _scooterRepository.insertScooter(resultScooter);
        await _loadScooters();
        if (mounted) _showSnackBar('Scooter aggiunto con successo!');
      } catch (e) {
        if (mounted) _showSnackBar('Errore nell\'aggiunta.');
      } finally {
        setState(() => _isProcessingAction = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bool isUIBlocked = _isLoading || _isProcessingAction;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Scooter'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: isUIBlocked ? null : () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen(themeService: widget.themeService))
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 28),
            onPressed: isUIBlocked ? null : _navigateToAddScooter,
          ),
        ],
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isUIBlocked,
            child: Opacity(
              opacity: isUIBlocked ? 0.5 : 1.0,
              child: Column(
                children: [
                  _buildTopLogo(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                    child: _scooters.isEmpty && !_isLoading
                        ? _buildEmptyState()
                        : _buildScooterList(),
                  ),
                ],
              ),
            ),
          ),
          if (isUIBlocked)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildTopLogo() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
            gradient: const RadialGradient(
              colors: [Colors.white, Colors.cyanAccent],
              stops: [0.9, 1.0],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/loghetto1_scritta128.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.two_wheeler, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.two_wheeler, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Nessuno scooter trovato.', style: TextStyle(color: Colors.grey)),
          Text('Premi "+" per aggiungerne uno!', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildScooterList() {
    return ListView.builder(
      itemCount: _scooters.length,
      itemBuilder: (context, index) {
        final scooter = _scooters[index];
        bool hasValidImage = scooter.imgPath != null && File(scooter.imgPath!).existsSync();

        return Dismissible(
          key: Key(scooter.id.toString()),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) => _confirmDelete(scooter),
          onDismissed: (direction) {
            // Chiamata immediata
            _deleteScooter(scooter);
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: hasValidImage ? Colors.blue : Colors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: hasValidImage
                      ? Image.file(File(scooter.imgPath!), fit: BoxFit.cover)
                      : const Icon(Icons.moped, color: Colors.grey),
                ),
              ),
              title: Text('${scooter.marca} ${scooter.modello}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Targa: ${scooter.targa}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScooterDetailScreen(scooter: scooter)),
                ).then((_) => _loadScooters());
              },
            ),
          ),
        );
      },
    );
  }
}