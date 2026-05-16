import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<bool> deleteScooter(String id) async {
    try {
      await _db.collection(_collectionName).doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteAllScooters() async {
    final userId = _currentUserId;
    if (userId == null) return;
    final snapshot = await _db.collection(_collectionName).where('userId', isEqualTo: userId).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}