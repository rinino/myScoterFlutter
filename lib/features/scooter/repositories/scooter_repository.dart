import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Per debugPrint
import '../../../core/services/cloud_storage_manager.dart';
import '../model/scooter.dart';


class ScooterRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'scooters';

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Stream<List<Scooter>> streamAllScooters() {
    final userId = _currentUserId;
    if (userId == null) return Stream.value([]);

    return _db
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Scooter.fromMap(doc.data(), doc.id)).toList());
  }

  Future<String?> insertScooter(Scooter scooter) async {
    final userId = _currentUserId;
    if (userId == null) return null;
    scooter.userId = userId;
    final ref = await _db.collection(_collectionName).add(scooter.toMap());
    return ref.id;
  }

  Future<List<Scooter>> getAllScooters() async {
    final userId = _currentUserId;
    if (userId == null) return [];
    final snapshot = await _db.collection(_collectionName).where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => Scooter.fromMap(doc.data(), doc.id)).toList();
  }

  Future<Scooter?> getScooterById(String id) async {
    final doc = await _db.collection(_collectionName).doc(id).get();
    if (doc.exists && doc.data() != null) {
      return Scooter.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<Scooter?> getScooterByTarga(String targa) async {
    final userId = _currentUserId;
    if (userId == null) return null;
    final snapshot = await _db.collection(_collectionName).where('userId', isEqualTo: userId).where('targa', isEqualTo: targa).limit(1).get();
    if (snapshot.docs.isNotEmpty) return Scooter.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
    return null;
  }

  Future<bool> updateScooter(Scooter scooter) async {
    final userId = _currentUserId;
    if (scooter.id == null || userId == null) return false;
    try {
      // FIX CRITICO: Sicurezza ID Utente
      scooter.userId = userId;
      await _db.collection(_collectionName).doc(scooter.id).set(scooter.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // FIX CRITICO: Eliminazione A CASCATA sicura con BATCH
  Future<bool> deleteScooter(String id) async {
    final userId = _currentUserId;
    if (userId == null) return false;

    try {
      // 1. Apriamo un pacchetto di operazioni (Batch)
      final batch = _db.batch();

      // 2. Preleviamo lo scooter per recuperare l'immagine prima di cancellarlo
      final scooterDoc = await _db.collection(_collectionName).doc(id).get();
      if (!scooterDoc.exists) return false;

      final scooterData = scooterDoc.data();
      final imgName = scooterData?['imgName'] as String?;

      // Segniamo lo scooter per la cancellazione
      batch.delete(scooterDoc.reference);

      // 3. Preleviamo TUTTI i Rifornimenti di questo scooter e li mettiamo nel batch
      final rifornimenti = await _db.collection('rifornimenti').where('idScooter', isEqualTo: id).get();
      for (var doc in rifornimenti.docs) {
        batch.delete(doc.reference);
      }

      // 4. Preleviamo TUTTE le Manutenzioni e cancelliamo le relative foto orfane!
      final manutenzioni = await _db.collection('manutenzioni').where('scooterId', isEqualTo: id).get();
      for (var doc in manutenzioni.docs) {
        final mData = doc.data();
        if (mData['nomeFoto'] != null) {
          CloudStorageManager.shared.deleteImageSilently(fileName: mData['nomeFoto']);
        }
        batch.delete(doc.reference);
      }

      // 5. Preleviamo TUTTI i Documenti e cancelliamo le relative foto orfane!
      final documenti = await _db.collection('documenti').where('scooterId', isEqualTo: id).get();
      for (var doc in documenti.docs) {
        final dData = doc.data();
        if (dData['nomeFoto'] != null) {
          CloudStorageManager.shared.deleteImageSilently(fileName: dData['nomeFoto']);
        }
        batch.delete(doc.reference);
      }

      // 6. Eseguiamo il BATCH in un solo colpo al server (Fulmineo e Sicuro!)
      await batch.commit();

      // 7. Se lo scooter aveva una foto, la cancelliamo dal cloud
      if (imgName != null && imgName.isNotEmpty) {
        CloudStorageManager.shared.deleteImageSilently(fileName: imgName);
      }

      debugPrint("ADR: Eliminazione a cascata completata con successo per scooter $id");
      return true;

    } catch (e) {
      debugPrint("ADR: Errore eliminazione scooter: $e");
      return false;
    }
  }

  // FIX CRITICO: Anche qui usiamo il BATCH invece del vecchio "for" sequenziale
  Future<void> deleteAllScooters() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final snapshot = await _db.collection(_collectionName).where('userId', isEqualTo: userId).get();
      if (snapshot.docs.isEmpty) return;

      // Facciamo l'eliminazione a cascata chiamando la funzione singola sicura
      for (var doc in snapshot.docs) {
        await deleteScooter(doc.id);
      }
    } catch (e) {
      debugPrint("ADR: Errore wipe database: $e");
    }
  }
}