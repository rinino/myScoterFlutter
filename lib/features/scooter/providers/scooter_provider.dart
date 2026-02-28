// lib/providers/scooter_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myscooter/features/scooter/model/scooter.dart';

// AGGIUNTO: Importiamo i nostri provider centrali (dove c'è scooterRepoProvider già configurato col database)
import 'package:myscooter/core/providers/core_providers.dart';

// Notifier che gestisce lo stato della lista (Loading, Data, Error)
class ScooterListNotifier extends AsyncNotifier<List<Scooter>> {

  @override
  Future<List<Scooter>> build() async {
    // Aggiungiamo un piccolo delay visivo come avevi originariamente
    await Future.delayed(const Duration(milliseconds: 800));
    // Ora ref.read legge il repository dal core_providers.dart!
    final repo = ref.read(scooterRepoProvider);
    return await repo.getAllScooters();
  }

  // Aggiunge uno scooter e ricarica la lista
  Future<void> addScooter(Scooter scooter) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(scooterRepoProvider);
      await repo.insertScooter(scooter);
      state = AsyncValue.data(await repo.getAllScooters());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Elimina uno scooter (compresa l'immagine fisica)
  Future<void> deleteScooter(Scooter scooter) async {
    // Salviamo lo stato attuale per eventuale rollback
    final previousData = state.value ?? [];

    // 1. Rimuoviamo SUBITO l'elemento dalla UI per evitare l'errore del Dismissible
    state = AsyncValue.data(previousData.where((s) => s.id != scooter.id).toList());

    try {
      // 2. Operazioni asincrone su File System e DB
      if (scooter.imgPath != null) {
        final file = File(scooter.imgPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await ref.read(scooterRepoProvider).deleteScooter(scooter.id!);

    } catch (e, st) {
      // In caso di errore, ripristiniamo la lista e notifichiamo l'errore
      state = AsyncValue.data(await ref.read(scooterRepoProvider).getAllScooters());
      state = AsyncValue.error("Errore durante l'eliminazione", st);
    }
  }

  // Forza il ricaricamento dei dati (utile quando torni dalla schermata di dettaglio)
  Future<void> refreshScooters() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await ref.read(scooterRepoProvider).getAllScooters());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Esponiamo il provider alla UI
final scooterListProvider = AsyncNotifierProvider<ScooterListNotifier, List<Scooter>>(() {
  return ScooterListNotifier();
});