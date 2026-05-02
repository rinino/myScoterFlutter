import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myscooter/features/scooter/model/scooter.dart';
import 'package:myscooter/core/providers/core_providers.dart';

class ScooterListNotifier extends AsyncNotifier<List<Scooter>> {
  @override
  Future<List<Scooter>> build() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final repo = ref.read(scooterRepoProvider);
    return await repo.getAllScooters();
  }

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

  Future<void> deleteScooter(Scooter scooter) async {
    final previousData = state.value ?? [];
    state = AsyncValue.data(previousData.where((s) => s.id != scooter.id).toList());

    try {
      // 1. Elimina immagine locale dello scooter
      if (scooter.imgName != null) {
        final file = File(scooter.imgName!);
        if (await file.exists()) await file.delete();
      }

      // 2. Elimina i documenti correlati su Firestore (Rifornimenti, Manutenzioni, Documenti)
      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      final rifornimenti = await db.collection('rifornimenti').where('idScooter', isEqualTo: scooter.id).get();
      for (var doc in rifornimenti.docs) {
        batch.delete(doc.reference);
      }

      final manutenzioni = await db.collection('manutenzioni').where('scooterId', isEqualTo: scooter.id).get();
      for (var doc in manutenzioni.docs) {
        batch.delete(doc.reference);
      }

      final documenti = await db.collection('documenti').where('scooterId', isEqualTo: scooter.id).get();
      for (var doc in documenti.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // 3. Elimina lo scooter stesso
      await ref.read(scooterRepoProvider).deleteScooter(scooter.id!);

    } catch (e, st) {
      // Rollback visivo in caso di errore
      state = AsyncValue.data(await ref.read(scooterRepoProvider).getAllScooters());
      state = AsyncValue.error("Errore durante l'eliminazione", st);
    }
  }

  Future<void> refreshScooters() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await ref.read(scooterRepoProvider).getAllScooters());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final scooterListProvider = AsyncNotifierProvider<ScooterListNotifier, List<Scooter>>(() {
  return ScooterListNotifier();
});