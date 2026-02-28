// lib/features/scooter/screens/home_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// --- IMPORT PER LE TRADUZIONI E MESSAGGI ---
import 'package:myscooter/features/scooter/providers/scooter_provider.dart';
import 'package:myscooter/core/theme/theme_service.dart';
import 'package:myscooter/core/providers/message_provider.dart';

import '../../../l10n/app_localizations.dart';
import '../model/scooter.dart';

class HomeScreen extends ConsumerWidget {
  final ThemeService themeService;

  const HomeScreen({super.key, required this.themeService});

  // Dialog di conferma prima dello swipe
  Future<bool?> _confirmDelete(BuildContext context, Scooter scooter) {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteScooterTitle),
        content: Text(l10n.deleteScooterContent(scooter.modello)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // --- 1. ASCOLTATORE MESSAGGI GLOBALI ---
    ref.listen<UiMessage?>(messageProvider, (previous, next) {
      if (next != null) {
        final Color? bgColor = next.type == MessageType.error
            ? Colors.red.shade800
            : (next.type == MessageType.success ? Colors.green.shade800 : null);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: bgColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(messageProvider.notifier).clear();
      }
    });

    // --- 2. ASCOLTATORE ERRORI SCOOTER ---
    ref.listen<AsyncValue<List<Scooter>>>(scooterListProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        // Usiamo errorLoading (da aggiungere agli .arb) o una traduzione generica
        ref.read(messageProvider.notifier).show(
            '${l10n.noDataPresent}: ${next.error}',
            type: MessageType.error
        );
      }
    });

    final scooterState = ref.watch(scooterListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: scooterState.isLoading ? null : () => context.push('/settings'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 28),
            onPressed: scooterState.isLoading ? null : () async {
              final Scooter? resultScooter = await context.push<Scooter?>('/add-edit-scooter');

              if (resultScooter != null) {
                await ref.read(scooterListProvider.notifier).addScooter(resultScooter);
                // CORRETTO: Stringa hardcoded rimossa
                ref.read(messageProvider.notifier).show(
                    l10n.scooterAdded,
                    type: MessageType.success
                );
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
                l10n.myScooters,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: scooterState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text(error.toString())),
              data: (scooters) => scooters.isEmpty
                  ? _buildEmptyState(context)
                  : _buildScooterList(context, ref, scooters),
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
          width: 120, height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withValues(alpha: 0.4),
                blurRadius: 15, spreadRadius: 2,
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

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.two_wheeler, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l10n.noScooterFound, style: const TextStyle(color: Colors.grey)),
          Text(l10n.addScooterPrompt, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildScooterList(BuildContext context, WidgetRef ref, List<Scooter> scooters) {
    final l10n = AppLocalizations.of(context)!;

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
            ref.read(scooterListProvider.notifier).deleteScooter(scooter);
            // CORRETTO: Stringa hardcoded rimossa
            ref.read(messageProvider.notifier).show(l10n.scooterDeleted);
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
                width: 60, height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: hasValidImage ? Colors.blue : Colors.grey.withValues(alpha: 0.3),
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
              // CORRETTO: Aggiunta label tradotta per la targa
              subtitle: Text('${l10n.licensePlateShort}: ${scooter.targa}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push('/scooter-detail', extra: scooter).then((_) {
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