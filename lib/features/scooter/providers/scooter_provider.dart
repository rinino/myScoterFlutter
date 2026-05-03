import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final db = FirebaseFirestore.instance;
      final storage = FirebaseStorage.instance;
      final batch = db.batch();

      // Funzione di supporto per pulire lo Storage
      Future<void> cancellaFotoDalCloud(String? path) async {
        if (path == null || path.isEmpty || userId == null) return;
        final fileName = path.split('/').last;
        try { await storage.ref().child("images/$userId/$fileName").delete(); } catch(_) {}
        try { final f = File(path); if (await f.exists()) await f.delete(); } catch(_) {}
      }

      // 1. Elimina foto Scooter
      await cancellaFotoDalCloud(scooter.imgName);

      // 2. Elimina Rifornimenti
      final rifornimenti = await db.collection('rifornimenti').where('idScooter', isEqualTo: scooter.id).get();
      for (var doc in rifornimenti.docs) batch.delete(doc.reference);

      // 3. Elimina Manutenzioni e le loro foto
      final manutenzioni = await db.collection('manutenzioni').where('scooterId', isEqualTo: scooter.id).get();
      for (var doc in manutenzioni.docs) {
        await cancellaFotoDalCloud(doc.data()['nomeFoto'] as String?);
        batch.delete(doc.reference);
      }

      // 4. Elimina Documenti e le loro foto
      final documenti = await db.collection('documenti').where('scooterId', isEqualTo: scooter.id).get();
      for (var doc in documenti.docs) {
        await cancellaFotoDalCloud(doc.data()['nomeFoto'] as String?);
        batch.delete(doc.reference);
      }

      await batch.commit();
      await ref.read(scooterRepoProvider).deleteScooter(scooter.id!);

    } catch (e, st) {
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