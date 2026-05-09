import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myscooter/features/scooter/model/scooter.dart';
import 'package:myscooter/core/providers/core_providers.dart';

class ScooterListNotifier extends StreamNotifier<List<Scooter>> {
  @override
  Stream<List<Scooter>> build() {
    final repo = ref.read(scooterRepoProvider);
    return repo.streamAllScooters();
  }

  Future<void> addScooter(Scooter scooter) async {
    await ref.read(scooterRepoProvider).insertScooter(scooter);
  }

  Future<void> deleteScooter(Scooter scooter) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final db = FirebaseFirestore.instance;
      final storage = FirebaseStorage.instance;
      final batch = db.batch();

      Future<void> cancellaFotoDalCloud(String? path) async {
        if (path == null || path.isEmpty || userId == null) return;
        final fileName = path.split('/').last;
        try { await storage.ref().child("images/$userId/$fileName").delete(); } catch(_) {}
        try { final f = File(path); if (await f.exists()) await f.delete(); } catch(_) {}
      }

      await cancellaFotoDalCloud(scooter.imgName);

      final rifornimenti = await db.collection('rifornimenti').where('idScooter', isEqualTo: scooter.id).get();
      // FIX: Aggiunte parentesi graffe al for
      for (var doc in rifornimenti.docs) {
        batch.delete(doc.reference);
      }

      final manutenzioni = await db.collection('manutenzioni').where('scooterId', isEqualTo: scooter.id).get();
      // FIX: Aggiunte parentesi graffe al for
      for (var doc in manutenzioni.docs) {
        await cancellaFotoDalCloud(doc.data()['nomeFoto'] as String?);
        batch.delete(doc.reference);
      }

      final documenti = await db.collection('documenti').where('scooterId', isEqualTo: scooter.id).get();
      // FIX: Aggiunte parentesi graffe al for
      for (var doc in documenti.docs) {
        await cancellaFotoDalCloud(doc.data()['nomeFoto'] as String?);
        batch.delete(doc.reference);
      }

      await batch.commit();
      await ref.read(scooterRepoProvider).deleteScooter(scooter.id!);

    } catch (e, st) {
      state = AsyncValue.error("Errore durante l'eliminazione", st);
    }
  }

  Future<void> refreshScooters() async {
    ref.invalidateSelf();
  }
}

final scooterListProvider = StreamNotifierProvider<ScooterListNotifier, List<Scooter>>(() {
  return ScooterListNotifier();
});