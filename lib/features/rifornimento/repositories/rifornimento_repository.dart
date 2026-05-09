import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myscooter/features/rifornimento/models/rifornimento.dart';

class RifornimentoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'rifornimenti';

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // NUOVO METODO STREAM
  Stream<List<Rifornimento>> streamRifornimentiForScooter(String scooterId) {
    final userId = _currentUserId;
    if (userId == null) return Stream.value([]);

    return _db
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('idScooter', isEqualTo: scooterId)
        .orderBy('dataRifornimento', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Rifornimento.fromMap(doc.data(), doc.id)).toList());
  }

  Future<String?> insertRifornimento(Rifornimento rifornimento) async {
    final userId = _currentUserId;
    if (userId == null) return null;
    rifornimento.userId = userId;
    final ref = await _db.collection(_collectionName).add(rifornimento.toMap());
    return ref.id;
  }

  Future<List<Rifornimento>> getRifornimentiForScooter(String scooterId) async {
    final userId = _currentUserId;
    if (userId == null) return [];
    final snapshot = await _db.collection(_collectionName).where('userId', isEqualTo: userId).where('idScooter', isEqualTo: scooterId).orderBy('dataRifornimento', descending: true).get();
    return snapshot.docs.map((doc) => Rifornimento.fromMap(doc.data(), doc.id)).toList();
  }

  Future<Rifornimento?> getRifornimentoById(String rifornimentoId) async {
    final doc = await _db.collection(_collectionName).doc(rifornimentoId).get();
    if (doc.exists && doc.data() != null) return Rifornimento.fromMap(doc.data()!, doc.id);
    return null;
  }

  Future<bool> updateRifornimento(Rifornimento rifornimento) async {
    if (rifornimento.id == null || _currentUserId == null) return false;
    try {
      await _db.collection(_collectionName).doc(rifornimento.id).set(rifornimento.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> deleteRifornimento(String rifornimentoId) async {
    try {
      await _db.collection(_collectionName).doc(rifornimentoId).delete();
      return 1;
    } catch (e) {
      return 0;
    }
  }

  Future<Rifornimento?> getPreviousRifornimento(String scooterId) async {
    final userId = _currentUserId;
    if (userId == null) return null;
    final snapshot = await _db.collection(_collectionName).where('userId', isEqualTo: userId).where('idScooter', isEqualTo: scooterId).orderBy('dataRifornimento', descending: true).limit(1).get();
    if (snapshot.docs.isNotEmpty) return Rifornimento.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
    return null;
  }

  Future<Rifornimento?> getPreviousRifornimentoExcluding(String scooterId, String? excludingRifornimentoId) async {
    final userId = _currentUserId;
    if (userId == null) return null;
    final snapshot = await _db.collection(_collectionName).where('userId', isEqualTo: userId).where('idScooter', isEqualTo: scooterId).orderBy('dataRifornimento', descending: true).limit(2).get();
    final rifornimenti = snapshot.docs.map((doc) => Rifornimento.fromMap(doc.data(), doc.id)).toList();
    try {
      return rifornimenti.firstWhere((rif) => rif.id != excludingRifornimentoId);
    } catch (e) {
      return null;
    }
  }
}