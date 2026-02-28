// lib/features/scooter/screens/home_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // <-- AGGIUNTO GO_ROUTER!

// Import corretti per l'architettura Feature-First

import 'package:myscooter/features/scooter/providers/scooter_provider.dart';
import 'package:myscooter/core/theme/theme_service.dart';

import '../model/scooter.dart';

// NOTA: Non serve più importare SettingsScreen, AddEditScooterScreen o ScooterDetailScreen!

class HomeScreen extends ConsumerWidget {
  final ThemeService themeService;

  const HomeScreen({super.key, required this.themeService});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Dialog di conferma prima dello swipe
  Future<bool?> _confirmDelete(BuildContext context, Scooter scooter) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ascoltiamo lo stato della lista degli scooter
    final scooterState = ref.watch(scooterListProvider);

    // Listener per catturare eventuali errori emessi dal provider e mostrare la Snackbar
    ref.listen<AsyncValue<List<Scooter>>>(scooterListProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        _showSnackBar(context, 'Si è verificato un errore: ${next.error}');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Scooter'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: scooterState.isLoading ? null : () {
            // ROUTING MODERNO: context.push invece di Navigator.push
            context.push('/settings');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 28),
            onPressed: scooterState.isLoading ? null : () async {
              // ROUTING MODERNO: Usiamo context.push tipizzato per aspettarci uno Scooter in ritorno
              final Scooter? resultScooter = await context.push<Scooter?>('/add-edit-scooter');

              if (resultScooter != null) {
                // Deleghiamo l'aggiunta al provider
                await ref.read(scooterListProvider.notifier).addScooter(resultScooter);
                if (context.mounted) _showSnackBar(context, 'Scooter aggiunto con successo!');
              }
            },
          ),
        ],
      ),
      body: Column(
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
            // Gestione automatica dei 3 stati (Caricamento, Errore, Dati)
            child: scooterState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const Center(child: Text('Errore di caricamento dati.')),
              data: (scooters) {
                if (scooters.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildScooterList(context, ref, scooters);
              },
            ),
          ),
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

  Widget _buildScooterList(BuildContext context, WidgetRef ref, List<Scooter> scooters) {
    return ListView.builder(
      itemCount: scooters.length,
      itemBuilder: (context, index) {
        final scooter = scooters[index];
        bool hasValidImage = scooter.imgPath != null && File(scooter.imgPath!).existsSync();

        return Dismissible(
          key: Key(scooter.id.toString()),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) => _confirmDelete(context, scooter),
          onDismissed: (direction) {
            // Deleghiamo l'eliminazione al provider
            ref.read(scooterListProvider.notifier).deleteScooter(scooter);
            _showSnackBar(context, 'Scooter eliminato.');
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
                // ROUTING MODERNO: Passiamo l'oggetto scooter tramite la proprietà "extra"
                context.push('/scooter-detail', extra: scooter).then((_) {
                  // Quando torniamo dai dettagli, aggiorniamo la lista nel caso ci siano state modifiche
                  ref.read(scooterListProvider.notifier).refreshScooters();
                });
              },
            ),
          ),
        );
      },
    );
  }
}