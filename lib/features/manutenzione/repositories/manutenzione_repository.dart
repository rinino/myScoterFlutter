import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myscooter/features/manutenzione/models/manutenzione.dart';

class ManutenzioneRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'manutenzioni';

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // NUOVO: Ascolto in tempo reale
  Stream<List<Manutenzione>> streamManutenzioni(String scooterId) {
    final userId = _currentUserId;
    if (userId == null) return Stream.value([]);

    return _db
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('scooterId', isEqualTo: scooterId)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Manutenzione.fromMap(doc.data(), doc.id)).toList());
  }

  Future<String?> insertManutenzione(Manutenzione manutenzione) async {
    final userId = _currentUserId;
    if (userId == null) return null;

    manutenzione.userId = userId;
    final ref = await _db.collection(_collectionName).add(manutenzione.toMap());
    return ref.id;
  }

  Future<List<Manutenzione>> getManutenzioni(String scooterId) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final snapshot = await _db
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('scooterId', isEqualTo: scooterId)
        .orderBy('data', descending: true)
        .get();

    return snapshot.docs.map((doc) => Manutenzione.fromMap(doc.data(), doc.id)).toList();
  }

  Future<bool> updateManutenzione(Manutenzione manutenzione) async {
    if (manutenzione.id == null || _currentUserId == null) return false;
    try {
      await _db.collection(_collectionName).doc(manutenzione.id).set(manutenzione.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> deleteManutenzione(String id) async {
    try {
      await _db.collection(_collectionName).doc(id).delete();
      return 1;
    } catch (e) {
      return 0;
    }
  }
}